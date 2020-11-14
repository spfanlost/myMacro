/**
  * @brief   find from internet, for self use.
  * @data    2020-03-01
  * @author  meng_yu
  * @copyright imyumeng@qq.com 2020
  */

/**
  * @brief  _getFileName
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
  * @brief  _getFileType
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
  * @brief  _hfileNameToMacro
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

function SkipCommentFromString(szLine,isCommentEnd)
{
    RetVal = ""
    fIsEnd = 1
    nLen = strlen(szLine)
    nIdx = 0
    while(nIdx < nLen )
    {
        if( (isCommentEnd == 0) || (szLine[nIdx] == "/" && szLine[nIdx+1] == "*"))
        {
            fIsEnd = 0
            while(nIdx < nLen )
            {
                if(szLine[nIdx] == "*" && szLine[nIdx+1] == "/")
                {
                    szLine[nIdx+1] = " "
                    szLine[nIdx] = " "
                    nIdx = nIdx + 1
                    fIsEnd  = 1
                    isCommentEnd = 1
                    break
                }
                szLine[nIdx] = " "
                nIdx = nIdx + 1
            }
            if(nIdx == nLen)
            {
                break
            }
        }
        if(szLine[nIdx] == "/" && szLine[nIdx+1] == "/")
        {
            szLine = strmid(szLine,0,nIdx)
            break
        }
        nIdx = nIdx + 1
    }
    RetVal.szContent = szLine;
    RetVal.fIsEnd = fIsEnd
    return RetVal
}

macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = 0
    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        nIdx = nIdx + 1
    }
    return strmid(szLine,nIdx,nLen)
}

macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    if(nLen == 0)
    {
        return szLine
    }
    nIdx = nLen
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    return strmid(szLine,0,nIdx+1)
}
function TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLine = TrimRight(szLine)
    return szLine
}

function strstr(str1,str2)
{
    i = 0
    j = 0
    len1 = strlen(str1)
    len2 = strlen(str2)
    if((len1 == 0) || (len2 == 0))
    {
        return 0xffffffff
    }
    while( i < len1)
    {
        if(str1[i] == str2[j])
        {
            while(j < len2)
            {
                j = j + 1
                if(str1[i+j] != str2[j])
                {
                    break
                }
            }
            if(j == len2)
            {
                return i
            }
            j = 0
        }
        i = i + 1
    }
    return 0xffffffff
}

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
    if (bFlg == FALSE)
        return ""
    if (cchEnd - cchStart <= 1)
        return ""
    szResult = strmid(szParaStr, cchStart, cchEnd)
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

function _getParaNameFromStr(szCut)
{
    iLen = strlen(szCut)
    if (iLen == 0)
        return "void#"
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
    iLen = strlen(szCut)
    szParaName = ""
    if (szCut[iLen - 1] == ")")
    {
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
        if (iStep != 2)
        {
            return "error#"
        }
        else
        {
            szParaName = strmid(szCut, cchNameStart, cchNameEnd + 1)
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
        iStep = 0
        cchNameEnd = 0
        cchNameStart = 0
        iCnt = iLen - 1
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
        if (iStep != 2)
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
        if (iCnt == -1)
        {
            szParaName = szCut
            szParaName = cat(szParaName, "#")
            return szParaName
        }
    }
    return "void#"
}

function _getFuncRetval(hSyml, hBuf)
{
    iCnt = hSyml.lnFirst
    iMax = hSyml.lnName
    szRetStr = ""
    szLine = ""
    while (iCnt < iMax)
    {
        szLine = GetBufLine(hBuf, iCnt)

        szLine = cat(szLine, " ")
        szRetStr = cat(szRetStr, szLine)
        iCnt++
    }
    szLine = GetBufLine(hBuf, iMax)
    szRetStr = cat(szRetStr, strmid(szLine, 0, hSyml.ichName))
    //add SkipCommentFromString ?
    szRetStr = _getRetvalTypeFromStr(szRetStr)
    return szRetStr
}

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

function _getFuncPara(hSyml, hBuf)
{
    iCnt = hSyml.lnName
    iMax = hSyml.lnLim
    fIsEnd = 1
    while (iCnt <= iMax)
    {
        szLine = GetBufLine(hBuf, iCnt)
        RetVal = SkipCommentFromString(szLine,fIsEnd)
        szLine = RetVal.szContent
        szLine = TrimString(szLine)
        fIsEnd = RetVal.fIsEnd
        ret = strstr(szLine,"{")
        if(ret != 0xffffffff)
        {
            szLine = strmid(szLine,0,ret)
            szParaStr = cat(szParaStr,szLine)
            break
        }
        szParaStr = cat(szParaStr,szLine)
        iCnt++
    }
    szPara = ""
    szPara.iParaNum = 0
    szPara.szParaStr = ""
    iLen = strlen(szParaStr)
    iCnt = 0
    cchStart = 0
    cchEnd = 0
    while (iCnt < iLen)
    {
        if ((szParaStr[iCnt] == ",")||(szParaStr[iCnt] == ")"))
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

macro SearchForWrd()
{
    LoadSearchPattern("&#&", 0, 0, 0);
    Search_Forward
}
macro SearchForCurrent()
{
    hbuf = GetCurrentBuf()
    str = GetBufSelText(hbuf)
    LoadSearchPattern(str, 0, 0, 0);
    /* 调用系统搜索命令 */
    Search_Forward
}
macro CommentSelStr()
{
    hbuf = GetCurrentBuf()
    str = GetBufSelText(hbuf)
    str = cat("/*",str)
    str = cat(str,"*/")
    SetBufSelText (hbuf, str)
}
macro CommentSingleLine()
{
    hbuf = GetCurrentBuf()
    ln = GetBufLnCur(hbuf)
    str = GetBufLine (hbuf, ln)
    str = cat("/*",str)
    str = cat(str,"*/")
    PutBufLine (hbuf, ln, str)
}
macro changeAuthor()
{
    szAuthor = ask("pls input your name:")
    if (strlen(szAuthor) == 0)
    {
        beep()
        stop
    }
    setreg(MYNAME, szAuthor)
}
macro quickAnnotate()
{
    /* 获取选择区收尾行 */
    handle = GetCurrentWnd()
    first_line = GetWndSelLnFirst(handle)
    last_line = GetWndSelLnLast(handle)

    /* 获取当前打开文件文本 */
    file_txt = GetCurrentBuf()

    if(GetBufLine(file_txt, 0)=="//magic-number:tph85666031")
    {
        stop
    }

    /* 决定最小非空格字符开始列数 */
    process_line = first_line
    min_process_column = 10000

    while(process_line <= last_line)
    {
        process_txt = GetBufLine(file_txt,process_line)
        process_txt_len = strlen(process_txt)

        if(process_txt == "")
        {
            process_line = process_line + 1
            continue
        }

        /* 查找非空格字符开始列数 */
        process_column = 0;

        while(process_column < process_txt_len)
        {
            if( process_txt[process_column] != " ")
            {
                break
            }
            process_column = process_column + 1
        }

        if(process_column < min_process_column)
        {
            min_process_column = process_column
        }

        process_line = process_line + 1
    }

    /* 逐行处理文本 */
    process_line = first_line

    while(process_line <= last_line)
    {
        process_txt = GetBufLine(file_txt,process_line)
        process_txt_len = strlen(process_txt)

        if(process_txt == "")
        {
            process_line = process_line + 1
            continue
        }

        /* 查找非空格字符开始列 */
        process_column = 0;

        while(process_column < process_txt_len)
        {
            if( process_txt[process_column] != " ")
            {
                break
            }
            process_column = process_column + 1
        }

        var buffer

        if(process_column < process_txt_len)
        {
            if(process_txt[process_column] == "/" && process_txt[process_column + 1] == "/")
            {
                /* 取消注释 补全缩进         */
                space = 0
                while(space < process_column)
                {
                    space = space + 1
                    buffer = cat(buffer," ");
                }

                space = 2
                if(process_txt[process_column + 2] == " ")
                {
                    space = 3
                }

                buffer = cat(buffer,strmid(process_txt,process_column + space,strlen(process_txt)))
                PutBufLine(handle,process_line,buffer)
            }
            else
            {
                /* 增加注释 补全缩进         */
                space = 0
                while(space < min_process_column)
                {
                    space = space + 1
                    buffer = cat(buffer," ");
                }

                buffer = cat(buffer,"// ")
                buffer = cat(buffer,strmid(process_txt, min_process_column, strlen(process_txt)))
                PutBufLine(handle,process_line,buffer)
            }
        }

        process_line = process_line + 1
    }
}

macro AddMacroComment()
{
    hwnd = GetCurrentWnd()
    sel = GetWndSel(hwnd)
    lnFirst = GetWndSelLnFirst(hwnd)
    lnLast = GetWndSelLnLast(hwnd)
    hbuf = GetCurrentBuf()
    BuflnCnt = GetBufLineCount(hbuf)
    if (LnFirst == 0)
        szIfStart = ""
    else
        szIfStart = GetBufLine(hbuf, LnFirst-1)
    //msg("WndlnCnt="#WndlnCnt# "sel.lnLast+1="#(sel.lnLast+1)# "lnLast+1="#(lnLast+1)#)
    if(BuflnCnt == (sel.lnLast+1))
        InsBufLine(hbuf, lnLast+1, "")
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

macro createFuncHeader()
{
    hWnd = GetCurrentWnd()
    if (hWnd == hNil)
        stop
    rSel = GetWndSel(hWnd)
    hBuf = GetWndBuf(hWnd)
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
    if (hSyml.Type == "Function Prototype" || hSyml.Type == "Function")
    {
        szRetval = _getFuncRetval(hSyml, hBuf)
        szPara_t = _getFuncPara(hSyml, hBuf)
        iLine = rSel.lnFirst + 1
        InsBufLine(hBuf,  iLine + 0, "/**")
        InsBufLine(hBuf,  iLine + 1, " * \@brief  This function &#&")
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

macro createFileHeader()
{
    hBuf = GetCurrentBuf()
    szFileName = _getFileName(hBuf)
    if (szFileName == "")
        szFileName = ask("File name empty, Pls input file name:")
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
    szAuthor = getreg(MYNAME)
    if (strlen(szAuthor) == 0)
    {
        szAuthor = ask("First time use, Pls input your name:")
        setreg(MYNAME, szAuthor)
    }
    //szCopyright = "xxx,Ltd."
    szCopyright = "imyumeng\@qq.com"
    InsBufLine(hBuf, 0, "/**")
    InsBufLine(hBuf, 1, " * \@file    @szFileName@")
    InsBufLine(hBuf, 2, " * \@author  @szAuthor@")
    InsBufLine(hBuf, 3, "")
    InsBufLine(hBuf, 4, " * \@version 0.0.1")
    InsBufLine(hBuf, 5, " * \@date    @Year@-@szMonth@-@szDay@")
    InsBufLine(hBuf, 6, " * ")
    InsBufLine(hBuf, 7, " * \@copyright Copyright (c) @Year@ @szCopyright@ All rigthts reserved.")
    InsBufLine(hBuf, 8, " */")
    InsBufLine(hBuf, 9, "")
    szFileType = _getFileType(szFileName)
    if (szFileType == "c" || szFileType == "C")
    {
        PutBufLine(hbuf,  3, " * \@brief   &#& function realize")
        InsBufLine(hBuf, 10, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 11, "  Private declaration  ")
        InsBufLine(hBuf, 12, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 13, "")
        InsBufLine(hBuf, 14, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 15, "  Extern variables declaration  ")
        InsBufLine(hBuf, 16, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 17, "")
        InsBufLine(hBuf, 18, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 19, "  Global variables definition  ")
        InsBufLine(hBuf, 20, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 21, "")
        InsBufLine(hBuf, 22, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 23, "  Local functions declaration  ")
        InsBufLine(hBuf, 24, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 25, "")
        InsBufLine(hBuf, 26, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 27, "  Local functions definition  ")
        InsBufLine(hBuf, 28, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 29, "")
        InsBufLine(hBuf, 30, "")
    }
    else if (szFileType == "h" || szFileType == "H")
    {
        PutBufLine(hbuf,  3, " * \@brief   &#& function header file")
        szHeaderMacro = _hfileNameToMacro(szFileName)
        InsBufLine(hBuf, 10, "#ifndef @szHeaderMacro@")
        InsBufLine(hBuf, 11, "#define @szHeaderMacro@")
        InsBufLine(hBuf, 12, "")
        InsBufLine(hBuf, 13, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 14, "  Exported types  ")
        InsBufLine(hBuf, 15, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 16, "")
        InsBufLine(hBuf, 17, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 18, "  Exported macro  ")
        InsBufLine(hBuf, 19, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 20, "")
        InsBufLine(hBuf, 21, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 22, "  Exported variables  ")
        InsBufLine(hBuf, 23, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 24, "")
        InsBufLine(hBuf, 25, "/*-----------------------------------------------------------------------------------")
        InsBufLine(hBuf, 26, "  Exported functions  ")
        InsBufLine(hBuf, 27, "-----------------------------------------------------------------------------------*/")
        InsBufLine(hBuf, 28, "")
        InsBufLine(hBuf, 29, "")
        InsBufLine(hBuf, 30, "#endif /* @szHeaderMacro@ */")
        InsBufLine(hBuf, 31, "")
    }
    SetBufIns(hBuf, 0, 0)
    SearchForWrd()
}

