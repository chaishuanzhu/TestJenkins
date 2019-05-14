# Jenkins 持续集成测试

参考：
https://www.jianshu.com/p/41ecb06ae95f. 
https://juejin.im/post/5ad6beff6fb9a028c06b5889. 

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