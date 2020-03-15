将Source Insight打造成好用的编辑器
[参考](http://www.armbbs.cn/forum.php?mod=viewthread&tid=95564&extra=page%3D1)
http://www.armbbs.cn/forum.php?mod=viewthread&tid=95564&extra=page%3D1
#一、比较冷门的小技巧
##1.列选
按住Alt键进行列选，SI列选是框区域
##2.TODO注释高亮
Options->>Preferencess->>SyntaxFormatting，勾选Special comment styles。
Options->>Style Properties，在Comment To Do条目设置代码高亮显示方式等。
#二、宏
SI的宏很有意思，像C语言语法，可以设置快捷键，提高编程效率。网上有一个Quicker.em宏，比较强大。
但是很多功能用不到，添加函数头注释要弹窗输入各个参数，我觉得编程时还是尽量少弹窗。
##0.使用方法
###添加入Base工程
将myMacro.em文件拷贝到C:\Users\你的用户名\Documents\Source Insight 4.0\Projects\Base路径下。
打开SI软件，选择Project->>Open Project，然后选择Base工程，将miniMacro.em加入工程中即可。
###设置快捷键
选择Options->>Key Assignments，搜索Macro，添加快捷键。
按照自己使用习惯设置快捷键，我的设置：
1. 将AddMacroComment设置为Ctrl+Q。// 宏注释“#ifdef 0”和“#endif”
2. 将quickAnnotate设置为Ctrl+1。// 快速注释或者消除注释 `//`
3. 将createFuncHeader设置为Ctrl+2。// 函数注释宏
4. 将createFileHeader设置为Ctrl+3。// 文件注释宏
5. 将SearchForWrd宏，设置Alt+1。// 向下搜索&#&，并选中
6. 将CommentSelStr宏，设置Alt+2。// 将一行中鼠标选中部分注释掉
7. 将CommentSingleLine宏，设置Alt+3。// 把光标显示的行注释掉


