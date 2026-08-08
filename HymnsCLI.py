#!/usr/bin/env python3
"""終端機詩歌本 HymnsCLI 主程式"""
import re
import argparse
from pathlib import Path
from os import system, name
from colorama import Fore, Style, init

init(autoreset=True)

HYMNS_DB = Path.home() / ".hymnsdb"
LASTBOOK_FILE = HYMNS_DB / ".lastbook"
BOOK_CODES = {
    "db": "詩歌本",
    "bb": "補充本",
    "er": "兒童詩歌",
    "xb": "新歌誦詠",
    "yb": "青年詩歌",
    "xg": "其他",
}


def clearScreen():
    system("cls") if name == "nt" else system("clear")


def getHighlightedHymn(filePath):
    lines = [l.strip() for l in Path(filePath).read_text(encoding="utf-8").splitlines()]
    i = 0
    number = title = note = key = None
    verses = []
    currentVerse = None

    if i < len(lines) and lines[i].isdigit():
        number = lines[i]
        i += 1
    if i < len(lines) and lines[i]:
        title = lines[i]
        i += 1
    if i < len(lines) and re.match(r"^（.*）$", lines[i]):
        note = lines[i]
        i += 1
    if i < len(lines) and re.search(r"[A-G](#|b)?(大|小)調", lines[i]):
        key = lines[i]
        i += 1

    for line in lines[i:]:
        if not line:
            continue
        if re.match(r"^[一二三四五六七八九十]$", line):
            currentVerse = {"label": line, "lines": []}
            verses.append(currentVerse)
        elif currentVerse:
            currentVerse["lines"].append(line)

    output = []
    if number:
        output.append(f"{Fore.LIGHTBLACK_EX}第 {number} 首{Style.RESET_ALL}\n")
    if title:
        output.append(f"{Style.BRIGHT}{Fore.YELLOW}{title}{Style.RESET_ALL}\n")
    meta = "　".join(filter(None, [note, key]))
    if meta:
        output.append(f"{Fore.CYAN}{meta}{Style.RESET_ALL}\n\n")
    for verse in verses:
        output.append(f"{Style.BRIGHT}{Fore.BLUE}【{verse['label']}】{Style.RESET_ALL}\n")
        output += [f"{l}\n" for l in verse["lines"]] + ["\n"]
    return "".join(output)


def loadLastBook():
    try:
        content = LASTBOOK_FILE.read_text(encoding="utf-8").strip()
        return content if len(content) == 2 else "db"
    except (FileNotFoundError, OSError):
        return "db"


def saveLastBook(book):
    try:
        HYMNS_DB.mkdir(parents=True, exist_ok=True)
        LASTBOOK_FILE.write_text(book, encoding="utf-8")
    except OSError as e:
        print(f"{Fore.RED}無法儲存選集紀錄：{e}{Style.RESET_ALL}")


def searchStringInFiles(targetString):
    matchedResults = {}
    if not HYMNS_DB.is_dir():
        return matchedResults
    for filePath in HYMNS_DB.rglob("*"):
        if not filePath.is_file():
            continue
        try:
            matchedLines = [
                line.strip()
                for line in filePath.read_text(encoding="utf-8").splitlines()
                if targetString in line
            ]
            if matchedLines:
                matchedResults[filePath.stem] = matchedLines
        except (UnicodeDecodeError, PermissionError, OSError):
            continue
    return matchedResults


def runInteractive():
    if not HYMNS_DB.is_dir():
        print(f"{Fore.RED}找不到資料庫資料夾：{HYMNS_DB}{Style.RESET_ALL}")
        print("請確認安裝腳本已正確執行，或手動將 .hymnsdb 放置於此路徑下。")
        return

    print("[用法說明]\n 不帶參數 一般詩歌本模式，須知道首數\n --search 查詢模式，用關鍵字查找詩歌\n")
    lastBook = loadLastBook()
    bookHint = "、".join(f"{code}={cname}" for code, cname in BOOK_CODES.items())
    print(bookHint)

    book = input(f"選擇詩集 [{lastBook}]：").strip()
    if len(book) != 2:
        book = lastBook
    saveLastBook(book)

    while True:
        raw = input("輸入首數：").strip()
        if raw.isdigit():
            number = int(raw)
            break
        print(f"{Fore.RED}請輸入正確的數字{Style.RESET_ALL}")

    targetPath = HYMNS_DB / book / f"{book}{number}.txt"
    if not targetPath.is_file():
        print(f"{Fore.RED}該詩歌不存在：{targetPath}{Style.RESET_ALL}")
        return

    try:
        result = getHighlightedHymn(targetPath)
    except OSError as e:
        print(f"{Fore.RED}讀取失敗：{e}{Style.RESET_ALL}")
        return

    clearScreen()
    print(result)


def runSearch():
    print("查詢關鍵字詞")
    key = input("關鍵字詞：").strip()
    clearScreen()
    print(f"搜尋字串：{key}")
    results = searchStringInFiles(key)
    if not results:
        print("查無符合的詩歌")
        return
    for fileStem, matchedLines in results.items():
        print(f"{fileStem}: ", end="")
        print(" / ".join(matchedLines))


def buildArgParser():
    parser = argparse.ArgumentParser(description="終端機詩歌本 HymnsCLI")
    parser.add_argument("--search", action="store_true", help="以關鍵字查詢詩歌")
    return parser


def main():
    args = buildArgParser().parse_args()
    if args.search:
        runSearch()
    else:
        runInteractive()


if __name__ == "__main__":
    main()
