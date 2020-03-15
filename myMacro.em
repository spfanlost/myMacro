/**
  * @brief   some find from internet, for self use.
  * @data    2020-03-01
  * @author  meng_yu
  * @copyright imyumeng@qq.com 2020 
  */

/**
  * @brief  获得文件名，包含后缀
  * @param  hBuf: 文件缓冲
  * @retval 文件名字符串
  */
function _getFileName(hBuf)
{
    szFileName = GetBufName(hBuf)
    iLen = strlen(szFileName)
    if (iLen == 0)
        return ""
    i = iLen
    while (i >= 0)
    {
        if (szFileName[i] == "\\")
        {
            szFileName = strmid(szFileName, i + 1, iLen)
            return szFileName
        }
        i--
    }
    return ""
}

/**
  * @brief  获得文件后缀
  * @param  szFileName: 文件名带后缀的
  * @retval 文件后缀
  */
function _getFileType(szFileName)
{
    szFileNameExt = ""
    iLen = strlen(szFileName)
    iCnt = iLen - 1
    while (iCnt >= 0)
    {
        if (szFileName[iCnt] == ".")
        {
            szFileNameExt = strmid(szFileName, iCnt + 1, iLen)
            return szFileNameExt
        }
        iCnt--
    }
    return ""
}

/**
  * @brief  把头文件名转换成宏，具体规则：
  *         头部加1个"_",非字母数字转换成"_",小写字母变大写,最后再加1个"_"
  * @param  szFileName: 文件名带后缀的
  * @retval 转换后的宏
  */
function _hfileNameToMacro(szFileName)
{
    szFileNameMacro = szFileName
    iLen = strlen(szFileNameMacro)
    iCnt = 0
    szFileNameMacro = toupper(szFileNameMacro)
    while (iCnt < iLen)
    {
        if ((isupper(szFileNameMacro[iCnt]) == TRUE) || (IsNumber(szFileNameMacro[iCnt]) == TRUE))
        {
            iCnt++
        }
        else
        {
            szFileNameMacro[iCnt] = "_"
            iCnt++
        }
    }
    szFileNameMacro = cat("_", szFileNameMacro)
    szFileNameMacro = cat(szFileNameMacro, "_")
    return szFileNameMacro
}

/**
  * @brief  消除字符串中的线注释“//”
  * @param  szLine: 字符串
  * @retval 返回处理过的字符串
  */
function _getStrNoLineAnnaotate(szLine)
{
    iLen = strlen(szLine)
    iCnt = 0
    szStr = szLine
    while (iCnt < (iLen-1))
    {
        if (szStr[iCnt] == "/" && szStr[iCnt+1] == "/")
        {
            szStr = strmid(szStr, 0, iCnt-1)
            return szStr
        }
        iCnt++
    }
    return szStr
}

/**
  * @brief  消除字符串中的块注释“/*”
  * @param  szLine: 已经消除了线注释“//”的字符串
  * @retval 返回处理过的字符串
  */
function _getStrNoBlockAnnaotate(szLine)
{
    iLen = strlen(szLine)
    iCnt = 0
    szStr = szLine
    ichFirst = 0
    ichLast = 0
    bFlg = FALSE                    /*!< 若查找到"/*"则不用再查找，以防注释是嵌套的 */
    while (iCnt < (iLen - 1))
    {
        if (szStr[iCnt] == "/" && szStr[iCnt + 1] == "*" && bFlg == FALSE)
        {
            ichFirst = iCnt
            bFlg = TRUE
        }
        else if (szStr[iCnt] == "*" && szStr[iCnt + 1] == "/" && bFlg == TRUE)
        {
            ichLast = iCnt + 2
            szStr = strmid(szStr, 0, ichFirst) # "" # strmid(szStr, ichLast, iLen)
            iLen = strlen(szStr)
            iCnt = ichFirst - 1
            bFlg = FALSE
        }
        iCnt++
    }
    return szStr
}

// 获得返回的数据类型
function _getRetvalTypeFromStr(szRetStr)
{
    chTab = CharFromAscii(9)
    chSpace = CharFromAscii(32);
    iLen = strlen(szRetStr)
    szStr = szRetStr
    iCnt = iLen - 1
    bFlg = FALSE
    iEnd = 0
    iStart = 0
    while (iCnt >= 0)
    {
        if (bflg == FALSE)
        {
            if (islower(szStr[iCnt]) == TRUE        /*!< 类型名只可能包含字母数字下划线 */
                || isupper(szStr[iCnt]) == TRUE
                || IsNumber(szStr[iCnt]) == TRUE
                || szStr[iCnt] == "_")
            {
                iEnd = iCnt + 1
                bFlg = TRUE
            }
        }
        else if (bFlg == TRUE)
        {
            if (szStr[iCnt] == chTab || szStr[iCnt] == chSpace)
            {
                iStart = iCnt + 1
                break
            }
        }
        iCnt--
    }
    szStr = strmid(szStr, iStart, iEnd)
    return szStr
}


/**
  * @brief  把字符串中开始的“()”参数截取出来
  * @param  szParaStr: 整个函数的字符串
  * @param  szSymlType: 字符串是函数还是函数声明
  * @retval 返回处理过的字符串，出错返回空
  */
function _getParaStrFromStr(szParaStr, szSymlType)
{
    iLen = strlen(szParaStr)
    bFlg = FALSE                        /*!< 找到第一个"("标志位 */
    iCnt = 0
    cchStart = 0
    cchEnd = 0
    if (szSymlType == "Function Prototype")
        szEnd = ";"
    else if (szSymlType == "Function")
        szEnd = "{"
    else
        return ""
    while (iCnt < iLen)
    {
        if ((szParaStr[iCnt] == "(") && (bFlg == FALSE))
        {
            cchStart = iCnt
            bFlg = TRUE
        }
        else if ((szParaStr[iCnt] == szEnd) && (bFlg == TRUE))
        {
            cchEnd = iCnt
            break
        }
        iCnt++
    }
    if (bFlg == FALSE)                  /*!< 没找到开头，没找到结尾在下一条if会处理 */
        return ""
    if (cchEnd - cchStart <= 1)             /*!< 这种情况应该不会出现 */
        return ""
    szResult = strmid(szParaStr, cchStart, cchEnd)
    // 去掉最前面的"("和最后面的")"
    iCnt = 0
    iLen = strlen(szResult)
    cchStart = 0
    cchEnd = 0
    while (iCnt < iLen)
    {
        if (szResult[iCnt] == "(")
        {
            cchStart = iCnt + 1
            break;
        }
        iCnt++
    }
    iCnt = iLen - 1
    while (iCnt >= 0)
    {
        if (szResult[iCnt] == ")")
        {
            cchEnd = iCnt
            break;
        }
        iCnt--
    }
    if (cchStart >= cchEnd)
        return ","
    szResult = strmid(szResult, cchStart, cchEnd)
    /* 从后往前再扫描这个字符串，如果遇见的第一个非空字符是","属于最后一个参数的，删掉 */
    chTab = CharFromAscii(9)
    chSpace = CharFromAscii(32);
    iLen = strlen(szResult)
    iCnt = iLen - 1
    while (iCnt >= 0)
    {
        if (szResult[iCnt] == chTab || szResult[iCnt] == chSpace)
        {
            iCnt--
        }
        else
        {
            szResult = strmid(szResult, 0, iCnt + 1)
            if (szResult[iCnt] != ",")
                szResult = cat(szResult, ",")
            break
        }
    }
    if (iCnt == -1)
        szResult = ","  
    return szResult
}

/**
  * @brief  传入一个表达式，内包含一个参数，提取出来，参数名后加一个"#"
  * @param  szCut: 表达式
  * @retval 返回参数名，无则返回void
  */
function _getParaNameFromStr(szCut)
{
    iLen = strlen(szCut)
    /* 如果没有参数，则返回void# */
    if (iLen == 0)
        return "void#"
    /* 去除右侧的空格 */
    chTab = CharFromAscii(9)
    chSpace = CharFromAscii(32);
    iCnt = iLen - 1
    while (iCnt >= 0)
    {
        if (szCut[iCnt] == chTab || szCut[iCnt] == chSpace)
        {
            iCnt--
        }
        else
        {
            szCut = strmid(szCut, 0, iCnt + 1)
            break
        }
    }
    /* 如果参数是数组或者函数指针，比较复杂，单独处理*/
    iLen = strlen(szCut)
    szParaName = ""
    if (szCut[iLen - 1] == ")")
    {
        /* 从左往右找到的第一个"()"就包含参数名 */
        iStep = 0
        cchNameEnd = 0
        cchNameStart = 0
        iCnt = 0
        while (iCnt < iLen)
        {
            if ((szCut[iCnt] == "(") && (iStep == 0))
            {
                cchNameStart = iCnt + 1
                iStep = 1
            }
            else if ((szCut[iCnt] == ")") && (iStep == 1))
            {
                cchNameEnd = iCnt - 1
                iStep = 2
                break
            }
            iCnt++
        }
        if (iStep != 2)                         /*!< 这种情况不会出现，除非语法错误 */
        {
            return "error#"
        }
        else
        {
            szParaName = strmid(szCut, cchNameStart, cchNameEnd + 1)
            /* 查找到单词 */
            bFlg = FALSE
            iLen = strlen(szParaName)
            iCnt = iLen - 1
            cchNameStart = 0
            cchNameEnd = iLen - 1
            while (iCnt >= 0)
            {
                if (((islower(szParaName[iCnt]) == TRUE) || (isupper(szParaName[iCnt]) == TRUE)
                    || (IsNumber(szParaName[iCnt]) == TRUE) || (szParaName[iCnt] == "_"))
                    && (bFlg == FALSE))
                {
                    cchNameEnd = iCnt
                    bFlg = TRUE
                }
                else if ((islower(szParaName[iCnt]) == FALSE) && (isupper(szParaName[iCnt]) == FALSE)
                    && (IsNumber(szParaName[iCnt]) == FALSE) && (szParaName[iCnt] != "_")
                    && (bFlg == TRUE))
                {
                    cchNameStart = iCnt + 1
                    break
                }
                iCnt--
            }
            szParaName = strmid(szParaName, cchNameStart, cchNameEnd + 1)
            szParaName = cat(szParaName, "#")
            return szParaName
        }
    }
    else if (szCut[iLen - 1] == "]")
    {
        iStep = 0                           /*!< 0 找"[", 1 找非空字符，2找单词结束*/
        cchNameEnd = 0
        cchNameStart = 0
        iCnt = iLen - 1
        /* 先找到“[”，再找到前面第一个单词就是数组名 */
        while (iCnt >= 0)
        {
            if ((szCut[iCnt] == "[") && (iStep == 0))
            {
                iStep = 1
            }
            else if ((szCut[iCnt] != chTab) && (szCut[iCnt] != chSpace) && (iStep == 1))
            {
                iStep = 2
                cchNameEnd = iCnt
            }
            else if ((islower(szCut[iCnt]) == FALSE) && (isupper(szCut[iCnt]) == FALSE)
                && (IsNumber(szCut[iCnt]) == FALSE) && (szCut[iCnt] != "_") && (iStep == 2))
            {
                cchNameStart = iCnt + 1
                break
            }
            iCnt--
        }
        if (iStep != 2)                 /*!< 这种情况不会出现，除非语法错误 */
        {
            return "error#"
        }
        else
        {
            szParaName = strmid(szCut, cchNameStart, cchNameEnd + 1)
            szParaName = cat(szParaName, "[]#")
            return szParaName
        }
    }
    else
    {
        while (iCnt >= 0)
        {
            if ((islower(szCut[iCnt]) == FALSE) && (isupper(szCut[iCnt]) == FALSE)
                && (IsNumber(szCut[iCnt]) == FALSE) && (szCut[iCnt] != "_"))
            {
                szParaName = strmid(szCut, iCnt + 1, iLen)
                szParaName = cat(szParaName, "#")
                return szParaName
            }
            iCnt--
        }
        if (iCnt == -1)                 /*!< 这种情况不会出现，除非语法错误 */
        {
            szParaName = szCut
            szParaName = cat(szParaName, "#")
            return szParaName
        }
    }
    return "void#"
}

/**
  * @brief  获得函数返回值类型
  * @param  hSyml: 函数的SymbolRecord
  * @param  hBuf: 文件缓冲
  * @retval 返回值类型字符串或者空
  */
function _getFuncRetval(hSyml, hBuf)
{
    iCnt = hSyml.lnFirst
    iMax = hSyml.lnName
    szRetStr = ""
    szLine = ""
    while (iCnt < iMax)
    {
        szLine = GetBufLine(hBuf, iCnt)
        szLine = _getStrNoLineAnnaotate(szLine)
        szLine = cat(szLine, " ")           /*!< 在处理的行后加个空格防止回车导致的单词连在一起*/
        szRetStr = cat(szRetStr, szLine)
        iCnt++
    }
    szLine = GetBufLine(hBuf, iMax)
    szRetStr = cat(szRetStr, strmid(szLine, 0, hSyml.ichName))
    szRetStr = _getStrNoBlockAnnaotate(szRetStr)
    szRetStr = _getRetvalTypeFromStr(szRetStr)
    return szRetStr
}
/**
  * @brief  从参数字符串分离出一个参数
  * @param  szParaStr: 参数字符串
  * @param  iCnt: 第几个参数 0 开始索引
  * @retval 返回参数名
  */
function _getOneParaName(szParaStr, iCnt)
{
    iLen = strlen(szParaStr)
    iIndex = 0
    iNum = 0
    cchStart = 0
    cchEnd = 0
    while (iIndex < iLen)
    {
        if (szParaStr[iIndex] == "#")
        {
            iNum++
            cchEnd = iIndex
            if ((iNum - iCnt) == 1)
                break
            cchStart = iIndex + 1
        }
        iIndex++
    }
    if (cchStart <= cchEnd)
    {
        return strmid(szParaStr, cchStart, cchEnd)
    }
    return "void"
}

/**
  * @brief  获得函数参数
  * @param  hSyml: 函数的SymbolRecord
  * @param  hBuf: 文件缓冲
  * @retval 返回值类型字符串或者空
  */
function _getFuncPara(hSyml, hBuf)
{
    iCnt = hSyml.lnName
    iMax = hSyml.lnLim - 1

    szLine = GetBufLine(hBuf, iCnt)
    szLine = strmid(szLine, strlen(hSyml.Symbol) + hSyml.ichName, GetBufLineLength(hBuf, iCnt))
    szLine = _getStrNoLineAnnaotate(szLine)
    szParaStr = cat(szLine, " ")
    iCnt++
    while (iCnt <= iMax)
    {
        szLine = GetBufLine(hBuf, iCnt)
        szLine = _getStrNoLineAnnaotate(szLine)
        szLine = cat(szLine, " ")
        szParaStr = cat(szParaStr, szLine)
        iCnt++
    }
    szParaStr = _getStrNoBlockAnnaotate(szParaStr)
    szParaStr = _getParaStrFromStr(szParaStr, hSyml.Type)

    /* 从参数字符串中提取出参数名 */
    szPara = ""
    szPara.iParaNum = 0
    szPara.szParaStr = ""
    iLen = strlen(szParaStr)
    iCnt = 0
    cchStart = 0
    cchEnd = 0
    while (iCnt < iLen)
    {
        if (szParaStr[iCnt] == ",")
        {
            cchEnd = iCnt
            szCut = strmid(szParaStr, cchStart, cchEnd)     /*!< 截取一个参数字符串*/
            szPara.szParaStr = cat(szPara.szParaStr, _getParaNameFromStr(szCut))
            szPara.iParaNum = szPara.iParaNum + 1
            cchStart = iCnt + 1
            cchEnd = iCnt + 1
        }
        iCnt++
    }
    return szPara
}

///< 向下搜索&#&，并选中。
macro SearchForWrd()
{
    LoadSearchPattern("&#&", 0, 0, 0);
    /* 调用系统搜索命令 */
    Search_Forward
}

///< 将一行中鼠标选中部分注释掉
macro CommentSelStr()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur(hbuf)
    str = GetBufSelText(hbuf)
    str = cat("/*",str)
    str = cat(str,"*/")
    SetBufSelText (hbuf, str)
}
///< 把光标显示的行注释掉
macro CommentSingleLine()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur(hbuf)
    str = GetBufLine (hbuf, ln)
    str = cat("/*",str)
    str = cat(str,"*/")
    PutBufLine (hbuf, ln, str)
}

///< 快速注释或者消除注释，选中区域的首行到尾行，不用全部选中。
macro quickAnnotate()
{
    /* 获得文件句柄 */
    hWnd = GetCurrentWnd()
    if (hWnd == hNil)
        stop
    /* 获得SelectRecord和文件缓冲句柄*/
    rSel = GetWndSel(hWnd)
    hBuf = GetWndBuf(hWnd)
    /* 检测是否所有行开头都有“//” */
    bFlg = TRUE
    iLn = rSel.lnFirst
    szLine = ""
    while (iLn <= rSel.lnLast)
    {
        szLine = GetBufLine(hBuf, iLn)
        if (strlen(szLine) >= 2)
        {
            if ((szLine[0] == "/") && (szLine[1] == "/"))
            {
                iLn++
            }
            else
            {
                bFlg = FALSE
                break
            }
        }
        else
        {
            bFlg = FALSE
            break
        }
    }
    if (bFlg == TRUE)                           /*!< 消除注释 */
    {
        iLn = rSel.lnFirst
        while (iLn <= rSel.lnLast)
        {
            szline = GetBufLine(hBuf, iLn)
            iLen = GetBufLineLength(hBuf, iLn)
            szLine = strmid(szLine, 2, iLen)
            PutBufLine(hBuf, iLn, szLine)
            iLn++
        }
    }
    else                                    /*!< 增加注释 */
    {
        iLn = rSel.lnFirst
        while (iLn <= rSel.lnLast)
        {
            szLine = GetBufLine(hBuf, iLn)
            szLine = cat("//", szLine)
            PutBufLine(hBuf, iLn, szLine)
            iLn++
        }
    }
    //SetBufIns(hBuf, rSel.lnFirst, 0)
    SetWndSel(hWnd, rSel)
}
///< 添加宏注释“#ifdef 0”和“#endif”
macro AddMacroComment()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf() 
    if (LnFirst == 0)
        szIfStart = ""
    else 
        szIfStart = GetBufLine(hbuf, LnFirst-1)
    szIfEnd = GetBufLine(hbuf, lnLast+1)
    if (szIfStart == "#if 0" && szIfEnd == "#endif")
    {
        DelBufLine(hbuf, lnLast+1)
        DelBufLine(hbuf, lnFirst-1)
        sel.lnFirst = sel.lnFirst-1 
        sel.lnLast = sel.lnLast-1
    }
    else
    {
        InsBufLine(hbuf, lnFirst, "#if 0")
        InsBufLine(hbuf, lnLast+2, "#endif")
        sel.lnFirst = sel.lnFirst+1 
        sel.lnLast = sel.lnLast+1
    } 
    SetWndSel(hwnd, sel)
}

///< 创建函数注释，可以是声明处，也可以是定义处
macro createFuncHeader()
{
    /* 获得文件句柄、SelectRecord、文件缓冲 */
    hWnd = GetCurrentWnd()
    if (hWnd == hNil)
        stop
    rSel = GetWndSel(hWnd)
    hBuf = GetWndBuf(hWnd)
    /* 先检查光标下面一行是否存在symbol */
    if (GetBufLineCount(hBuf) <= (rSel.lnFirst + 1))
    {
        beep()
        stop
    }
    hSyml = GetSymbolLocationFromLn(hBuf, rSel.lnFirst + 1)
    if (hSyml == "")
    {
        beep()
        stop
    }
    /* 再检测symbol类型是不是函数声明或者函数定义 */
    if (hSyml.Type == "Function Prototype" || hSyml.Type == "Function")
    {
        szRetval = _getFuncRetval(hSyml, hBuf)    /*!< 先获得返回值类型 */
        szPara_t = _getFuncPara(hSyml, hBuf)    /*!< 再获得参数类型结构体数据 */
        iLine = rSel.lnFirst + 1
        InsBufLine(hBuf,  iLine + 0, "/**")
        InsBufLine(hBuf,  iLine + 1, " * \@brief  &#&")
        iCnt = 0
        while (iCnt < szPara_t.iParaNum)
        {
            szParaName = _getOneParaName(szPara_t.szParaStr, iCnt)
            if (szParaName == "void")
            {
                szParaName = "None"
                InsBufLine(hBuf,  iLine + 2 + iCnt, " * \@param  @szParaName@")
            }
            else
            {
                InsBufLine(hBuf,  iLine + 2 + iCnt, " * \@param  @szParaName@: &#&")
            }
            iCnt++
        }
        if (szRetval == "void")
        {
            InsBufLine(hBuf,  iLine + 2 + iCnt, " * \@note:  &#&")
            InsBufLine(hBuf,  iLine + 3 + iCnt, " */")
        }
        else 
        {
            InsBufLine(hBuf,  iLine + 2 + iCnt, " * \@return &#&")
            InsBufLine(hBuf,  iLine + 3 + iCnt, " * \@retval &#&")
            InsBufLine(hBuf,  iLine + 4 + iCnt, " * \@note:  &#&")
            InsBufLine(hBuf,  iLine + 5 + iCnt, " */")
        }
        SetBufIns(hBuf, iLine, 0)
        SearchForWrd()
    }
    else
    {
        beep()
        stop
    }
}

///< 创建文件头注释，自动识别文件类型
macro createFileHeader()
{
    hBuf = GetCurrentBuf()
    szFileName = _getFileName(hBuf)
    if (szFileName == "")
        szFileName = ask("Pls input file name:")
    szTime = GetSysTime(1)
    // Hour = szTime.Hour
    // Minute = szTime.Minute
    // Second = szTime.Second
    Day = szTime.Day
    Month = szTime.Month
    Year = szTime.Year 
    if (Day < 10) 
        szDay = "0@Day@" 
    else 
        szDay = Day
    if (Month < 10) 
        szMonth = "0@Month@" 
    else 
        szMonth = Month

    szAuthor = "meng_yu"
    szCopyright = "Copyright (c) @Year@, meng_yu imyumeng\@qq.com" 
    InsBufLine(hBuf, 0, "/**")
    InsBufLine(hBuf, 1, " * \@file    @szFileName@")
    InsBufLine(hBuf, 2, " * \@author  @szAuthor@")
    InsBufLine(hBuf, 3, " * \@brief   &#& function realize")
    InsBufLine(hBuf, 4, " * \@version 0.0.1")
    InsBufLine(hBuf, 5, " * \@date    @Year@-@szMonth@-@szDay@")
    InsBufLine(hBuf, 6, " * ")
    InsBufLine(hBuf, 7, " * \@copyright @szCopyright@")
    InsBufLine(hBuf, 8, " */")
    InsBufLine(hBuf, 9, "")
    szFileType = _getFileType(szFileName)
    if (szFileType == "h" || szFileType == "H")
    {
        szHeaderMacro = _hfileNameToMacro(szFileName)
        InsBufLine(hBuf, 10, "#ifndef @szHeaderMacro@")
        InsBufLine(hBuf, 11, "#define @szHeaderMacro@")
        InsBufLine(hBuf, 12, "")
        InsBufLine(hBuf, 13, "/* Includes ------------------------------------------------------------------*/")
        InsBufLine(hBuf, 14, "/* Exported types ------------------------------------------------------------*/")
        InsBufLine(hBuf, 15, "/* Exported macro ------------------------------------------------------------*/")
        InsBufLine(hBuf, 16, "/* Exported variables --------------------------------------------------------*/")
        InsBufLine(hBuf, 17, "/* Exported functions --------------------------------------------------------*/")
        InsBufLine(hBuf, 18, "")
        InsBufLine(hBuf, 19, "")
        InsBufLine(hBuf, 20, "#endif /* @szHeaderMacro@ */")
        InsBufLine(hBuf, 21, "")
    }
    else if (szFileType == "c" || szFileType == "C")
    {
        InsBufLine(hBuf, 10, "/* Includes ------------------------------------------------------------------*/")
        InsBufLine(hBuf, 11, "/* Private declaration -------------------------------------------------------*/")
        InsBufLine(hBuf, 12, "/* Extern variables declaration ----------------------------------------------*/")
        InsBufLine(hBuf, 13, "/* Global variables definition -----------------------------------------------*/")
        InsBufLine(hBuf, 14, "/* Local functions declaration -----------------------------------------------*/")
        InsBufLine(hBuf, 15, "/* Local functions definition ------------------------------------------------*/")
        InsBufLine(hBuf, 18, "")
        InsBufLine(hBuf, 19, "")
    }
    SetBufIns(hBuf, 0, 0)
    SearchForWrd()
}
