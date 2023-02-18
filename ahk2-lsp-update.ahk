if A_IsCompiled {
	if A_Args.Length && FileExist(A_Args[1])
		script := A_Args[1]
	else if !FileExist(script := RegExReplace(A_AhkPath, 'i)\.exe$', '.ahk'))
		script := ''
	if script
		Run('"' A_AhkPath '" /restart /script "' script '"'), ExitApp()
}

githubsites := ['https://hub.fastgit.xyz', 'https://github.com']
package := A_ScriptDir '\package.json'
if FileExist(package) {
	if !(version := getVersion())
		installAHKLSP()
	else {
		whr := ComObject('WinHttp.WinHttpRequest.5.1')
		whr.Option[0] := 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Edg/89.0.774.68'
		for url in githubsites {
			whr.Open('GET', url '/thqby/vscode-autohotkey2-lsp/blob/server/package.json', true)
			whr.Send()
			try {
				whr.WaitForResponse(10000)
				text := whr.ResponseText
				if (beg := InStr(text, match := '<span class="pl-ent">&quot;version&quot;</span>: <span class="pl-s"><span class="pl-pds">&quot;</span>')) && (end := InStr(text, '<span ', , beg += StrLen(match))) {
					version_new := SubStr(text, beg, end - beg)
					if VerCompare(version_new, version) > 0
						installAHKLSP()
					break
				}
			} catch
				whr.Abort()
		}
	}
} else installAHKLSP()

getVersion() => RegExMatch(FileRead(package, 'utf-8'), 'i)"version":\s*"(.*?)"', &m) ? m[1] : ''
installAHKLSP() {
	try FileDelete(zip := A_Temp '\server.zip')
	for url in githubsites
		try {
			Download(url '/thqby/vscode-autohotkey2-lsp/archive/refs/heads/server.zip', zip)
			break
		}
	if !FileExist(zip)
		TrayTip('vscode-autohotkey2-lsp download fail.')
	else {
		oshell := ComObject('Shell.Application')
		oshell.NameSpace(A_ScriptDir).CopyHere(oshell.NameSpace(zip '\vscode-autohotkey2-lsp-server').Items(), 4 | 16)
		FileDelete(zip)
		if version := getVersion()
			TrayTip('vscode-autohotkey2-lsp v' version ' has been installed.')
	}
}