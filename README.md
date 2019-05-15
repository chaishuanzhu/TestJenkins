# Jenkins 持续集成测试

参考：
https://www.jianshu.com/p/41ecb06ae95f.  
https://juejin.im/post/5ad6beff6fb9a028c06b5889.  
https://www.runoob.com/linux/linux-shell.html  
https://github.com/chaishuanzhu/iOSShell.   
https://huixisheng.github.io/jenkins-email/  
https://liuhongjiang.github.io/hexotech/2015/12/04/jenkins-send-email-after-build/     
https://www.w3cschool.cn/groovy/groovy_overview.html   

## 1.安装Jenkins
```
brew install jenkins
```

## 2.启动和停止
```
jenkins server

brew services start jenkins

brew services restart jenkins

brew services stop jenkins
```

## 3.安装插件 
建议选择 Install suggested plugins。  
登录 http://localhost:8080 ，选择“系统管理”——“管理插件”,在“可选插件”中选中“GitLab Plugin”、“Gitlab Hook Plugin”、“Xcode integration"等常用插件，然后安装。

## 4.创建项目
参考链接 
## 5.sh脚本
```
echo "执行pod install"
pod install
echo "pod 执行完毕"
echo "开始下载依赖"
# wget -p $WORKSPACE/Frameworks http://127.0.0.1/xxxx.framework
```

```
BUILD_TYPE="Release"
SCHEME_NAME="TestJenkins"

# 上传到蒲公英
PGYER_U_KEY="44a10b958afa3846268912d695d2a44e"
PGYER_API_KEY="b4656bb3b89d68836bab2258666ec1ed"


# 编译生成文件目录
EXPORT_PATH="$WORKSPACE/build"

# 指定输出文件目录不存在则创建
if test -d "$EXPORT_PATH" ; then
echo ">>>>>>>>>>>>>>>>>>>保存归档文件和ipa的路径=$EXPORT_PATH "
rm -rf $EXPORT_PATH
else
mkdir -pv $EXPORT_PATH
fi

# 归档文件路径

EXPORT_ARCHIVE_PATH="$EXPORT_PATH/$SCHEME_NAME.xcarchive"
# ipa 导出路径
EXPORT_IPA_PATH="$EXPORT_PATH"

echo ">>>>>>>>>>>>>>>>>>>开始构建项目，当前选择构建类型：" + $BUILD_TYPE 
echo ">>>>>>>>>>>>>>>>>>>当前 workspace " +$WORKSPACE
if [ $BUILD_TYPE == "Release"]; 
then 
	xcodebuild archive -workspace $WORKSPACE/$SCHEME_NAME.xcworkspace -archivePath $EXPORT_ARCHIVE_PATH -sdk iphoneos -scheme $SCHEME_NAME -configuration Release
else 
	xcodebuild archive -workspace $WORKSPACE/$SCHEME_NAME.xcworkspace -archivePath $EXPORT_ARCHIVE_PATH -sdk iphoneos -scheme $SCHEME_NAME -configuration Debug
fi

# 检查是否构建成功
# xcarchive 实际是一个文件夹不是一个文件所以使用 -d 判断
if test -d "$EXPORT_ARCHIVE_PATH" ; then
echo ">>>>>>>>>>>>>>>>>>>项目构建成功 🚀 🚀 🚀 "
else
echo ">>>>>>>>>>>>>>>>>>>项目构建失败 😢 😢 😢 "
exit 1
fi

echo ">>>>>>>>>>>>>>>>>>>开始导出ipa文件 "
xcodebuild -exportArchive -archivePath $EXPORT_ARCHIVE_PATH -exportPath $EXPORT_IPA_PATH -exportOptionsPlist $WORKSPACE/build/AdHocExportOptionsPlist.plist -allowProvisioningUpdates

# 检查文件是否存在
if test -f "$EXPORT_IPA_PATH/$SCHEME_NAME.ipa" ; then
echo ">>>>>>>>>>>>>>>>>>>导出 $EXPORT_IPA_PATH/$SCHEME_NAME.ipa 包成功 🎉 🎉 🎉 "
fi

# 上传到蒲公英
RESULT=$(curl -F "file=@$EXPORT_IPA_PATH/$SCHEME_NAME.ipa" \
-F "uKey=$PGYER_U_KEY" \
-F "_api_key=$PGYER_API_KEY" \
"http://www.pgyer.com/apiv1/app/upload")

cat>pgyer.json<<EOF
$RESULT
EOF


echo " 上传 $SCHEME_NAME.ipa 包 到 pgyer 成功 🎉 🎉 🎉 "
```

## 6.邮件通知

系统管理员邮件地址: Jenkins管理员<870027381@qq.com>

Manage Jenkins -> Configure System -> Extended E-mail Notification
```
SMTP server: smtp.qq.com 

User Name: 邮箱账号
Password: 开通SMTP时生成的密码
SMTP port: 587

Default Content Type: HTML

Default Subject: 

[Jenkins构建通知]$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!

Default Content: 
----------------------------------------------------------------------
(邮件由Jenkins自动发出，请勿回复~)<br>
项目名称：$PROJECT_NAME<br>
构建编号：$BUILD_NUMBER<br>
构建状态：$BUILD_STATUS<br>
触发原因：${CAUSE}<br>
构建地址：<a href="${BUILD_URL}">点击跳转</a><br>
构建输出日志：<a href="${BUILD_URL}console">查看日志</a><br>
下载地址：<a href="https://www.pgyer.com/app/downloadurl">点击下载</a><br><br>
二维码下载：<br>
<img src="https://www.pgyer.com/app/qrcodeurl" alt="扫码下载"><br>
最近修改：<br>${CHANGES, showPaths=false, format="%a：\"%m\"<br>", pathFormat="\n\t- %p"}
------------------------------------------------------------------------
Default Pre-send Script:
------------------------------------------------------------------------
import groovy.json.JsonSlurper
def var = build.getEnvVars()
// 修改邮件内容
// pgyresult {"code":0,"message":"","data":{"appKey":"1489b14b592e0bde8260bc46473565b7","userKey":"44a10b958afa3846268912d695d2a44e","appType":"1","appIsLastest":"1","appFileSize":"137535","appName":"TestJenkins","appVersion":"1.0","appVersionNo":"1","appBuildVersion":"34","appIdentifier":"com.xxx.TestJenkins","appIcon":"","appDescription":"","appUpdateDescription":"","appScreenshots":"","appShortcutUrl":"iq6d","appCreated":"2019-05-15 10:21:47","appUpdated":"2019-05-15 10:21:47","appQRCodeURL":"http:\/\/www.pgyer.com\/app\/qrcodeHistory\/2d90214b7dd150cdb53174d78efd3e7148cdd4617f7bf1950adc89eb1f6fcd7b"}}
def pgyFile = var.get("WORKSPACE") + "/pgyer.json"
def pgyresult = new File(pgyFile).text
logger.print("pgyresult is: $pgyresult")
def jsonSlurper = new JsonSlurper()
def object = jsonSlurper.parseText(pgyresult)
def emailContent = msg.getContent().getBodyPart(0).getContent()
logger.print("emailContent is: $emailContent")
emailContent = emailContent.replaceAll("https://www.pgyer.com/app/downloadurl", "https://www.pgyer.com/"+object.data.appShortcutUrl)
emailContent = emailContent.replaceAll("https://www.pgyer.com/app/qrcodeurl", object.data. appQRCodeURL)
logger.print("emailContent is: $emailContent")
msg.setContent(emailContent, "text/html; charset=utf-8");
--------------------------------------------------------------------------
Default Triggers: Always
```

项目设置-> 构建后操作 -> Editable Email Notification
```
# 多个用空格隔开
Project Recipient List: 870027381@qq.com 12123@qq.com
```
