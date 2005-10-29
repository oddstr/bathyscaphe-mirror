property autostart : false
property autoquit : false
property defaultURL : ""
--
property wherefolder : ""
property bundlePath : ""
property defPlistPath : ""
property downloadedhtmlPath : ""
property ifplistexist : ""
property needtoRemove : false
property parentAppName : "BathyScaphe"
property BWAgentDefaultURL : "http://azlucky.s25.xrea.com/2chboard/bbsmenu2.html"

on clicked theObject
	if name of theObject is "update" then
		my startsync()
	else if name of theObject is "cancel" then
		quit
	end if
end clicked

on will open theObject
	registerSettings()
	readSettings()
	checkfolder()
	tell theObject
		if wherefolder is "" then
			set contents of text field "message" to localized string "msg_alt"
			set title of button "update" to localized string "label_alt"
		else
			set folPath to (POSIX path of wherefolder)
			set ifplistexist to (do shell script "find " & quoted form of folPath & " -name board_default.plist")
			if (ifplistexist is "") then
				set contents of text field "message" to localized string "msg_alt"
				set title of button "update" to localized string "label_alt"
			end if
		end if
		set contents of combo box "combo_url" to defaultURL
	end tell
end will open

on will finish launching theObject
	if autostart then
		my startsync()
	end if
end will finish launching

on will quit theObject
	set defaultURL to contents of combo box "combo_url" of window "mainwindow"
	writeSettings()
	if needtoRemove then
		try
			do shell script "rm " & downloadedhtmlPath
		end try
	end if
end will quit

on alert ended theObject with reply withReply
	set dBtnName to localized string "btn_ok"
	if button returned of withReply is dBtnName then quit
end alert ended

on checkfolder()
	set defPlistPath to ""
	set wherefolder to ""
	set AppSupportPath to (path to application support from user domain)
	set TmpItemsPath to (path to temporary items from system domain)
	set bundlePath to (resource path of main bundle) & "/"
	--
	tell application "Finder"
		if exists alias file "Documents" of folder parentAppName of AppSupportPath then
			set wherefolder to (original item of alias file "Documents" of folder parentAppName of AppSupportPath) as alias
			set defPlistPath to quoted form of ((POSIX path of wherefolder) & "board_default.plist")
		else if exists folder "Documents" of folder parentAppName of AppSupportPath then
			set wherefolder to (folder "Documents" of folder parentAppName of AppSupportPath) as alias
			set defPlistPath to quoted form of ((POSIX path of wherefolder) & "board_default.plist")
		else if exists alias file parentAppName of AppSupportPath then
			if exists folder "Documents" of (original item of alias file parentAppName of AppSupportPath) then
				set wherefolder to (folder "Documents" of (original item of alias file parentAppName of AppSupportPath)) as alias
			else if exists alias file "Documents" of (original item of alias file parentAppName of AppSupportPath) then
				set wherefolder to (original item of alias file "Documents" of (original item of alias file parentAppName of AppSupportPath)) as alias
			end if
			set defPlistPath to quoted form of ((POSIX path of wherefolder) & "board_default.plist")
		else
			do shell script "mkdir -p " & quoted form of ((POSIX path of AppSupportPath) & parentAppName & "/Documents")
			set defPlistPath to quoted form of ((POSIX path of AppSupportPath) & parentAppName & "/Documents/board_default.plist")
		end if
	end tell
	set downloadedhtmlPath to quoted form of ((POSIX path of TmpItemsPath) & "bbsmenu.html")
end checkfolder

on checkifURLisValid(theURL)
	if (theURL starts with "http://") and (theURL ends with "html") then
		return theURL
	else
		return BWAgentDefaultURL
	end if
end checkifURLisValid

on startsync()
	progressControl(1)
	set defaultURL to my checkifURLisValid(contents of combo box "combo_url" of window "mainwindow")
	log "Using this URL:" & defaultURL
	--
	set resultofDhtml to my downloadbbsmenu()
	log resultofDhtml
	if resultofDhtml begins with "err:" then
		beep
		set theTitle to localized string "word_errstep0"
		set dBtnName to localized string "btn_ok"
		set theMsg to localized string "msg_errstep0"
		display alert theTitle as warning message theMsg default button dBtnName attached to window "mainwindow"
		progressControl(2)
		return
	end if
	--
	set resultofDList to my updateDefaultList()
	if resultofDList is "err" then
		beep
		set theTitle to localized string "word_errstep1"
		set dBtnName to localized string "btn_ok"
		set theMsg to localized string "msg_errstep1"
		display alert theTitle as warning message theMsg default button dBtnName attached to window "mainwindow"
		progressControl(2)
		return
	end if
	--
	if wherefolder is not "" then
		set resultofUList to my syncUsrList()
		if resultofUList is "err" then
			beep
			set theTitle to localized string "word_errstep2"
			set dBtnName to localized string "btn_ok"
			set theMsg to localized string "msg_errstep2"
			display alert theTitle as warning message theMsg default button dBtnName attached to window "mainwindow"
			progressControl(2)
			return
		else if resultofUList is "noexist" then
			set contents of text field "message" of window "mainwindow" to localized string "msg_default"
			set title of button "update" of window "mainwindow" to localized string "label_default"
		end if
	else
		set contents of text field "message" of window "mainwindow" to localized string "msg_default"
		set title of button "update" of window "mainwindow" to localized string "label_default"
	end if
	if autoquit then
		log "Successfully Updated, and automatically quitting BWAgent..."
		quit
	else
		beep
		set dBtnName to localized string "btn_ok"
		--set theinfo to ""
		if ifplistexist is "" then
			set theTitle to localized string "status_fin_alt"
		else
			set theTitle to localized string "status_fin"
			(*if resultofUList is 0 then
				set theinfo to (localized string "msg_info")
			else
				set theinfo to (localized string "msg_infopart1") & resultofUList & (localized string "msg_infopart2")
			end if*)
		end if
		display alert theTitle as warning message "" default button dBtnName attached to window "mainwindow"
		--display alert theTitle as warning message theinfo default button dBtnName attached to window "mainwindow"
	end if
	progressControl(2)
end startsync

on downloadbbsmenu()
	set needtoRemove to false
	
	set myfol to (path to temporary items from system domain) as string
	set myfol to myfol & "bbsmenu.html"
	set myfile to myfol as file specification
	
	tell application "URL Access Scripting"
		try
			with timeout of 180 seconds
				download defaultURL to myfile replacing yes
			end timeout
		on error errMsg number errNum
			return "err:" & errMsg
		end try
	end tell
	set needtoRemove to true
	return "download succeeded"
end downloadbbsmenu

on updateDefaultList()
	set plPath to quoted form of (bundlePath & "sora.pl")
	set ftoolPath to quoted form of (bundlePath & "SJIS2UTF8")
	set ifplistexist to ""
	set myresult to ""
	if wherefolder is not "" then
		set folPath to (POSIX path of wherefolder)
		if not (ifplistexist is "") then
			do shell script "cp " & quoted form of (folPath & "board_default.plist") & " " & quoted form of (folPath & "board_default~.plist")
		end if
	end if
	try
		set myscript to "perl " & plPath & " " & downloadedhtmlPath & " " & ftoolPath & " > " & defPlistPath
		set myresult to do shell script myscript
	on error
		log "do shell scpt cmd returns: " & myresult
		return "err"
	end try
	return myresult
end updateDefaultList

on syncUsrList()
	set argvPOSIX to quoted form of ((POSIX path of wherefolder) & "board.plist")
	set ifplistexist to (do shell script "find " & quoted form of (POSIX path of wherefolder) & " -name board.plist")
	set myresult to ""
	if (ifplistexist is "") then
		return "noexist"
	end if
	set plPath to quoted form of (bundlePath & "rosetta.pl")
	try
		do shell script "cp " & argvPOSIX & " " & quoted form of ((POSIX path of wherefolder) & "board~.plist")
		set myscript to "perl " & plPath & " " & downloadedhtmlPath & " " & argvPOSIX
		set myresult to do shell script myscript
		if myresult is not "" then
			log myresult
			set myresult to (count of paragraphs of myresult)
		else
			set myresult to 0
		end if
	on error
		log "do shell scpt cmd returns: " & myresult
		return "err"
	end try
	return myresult
end syncUsrList

on progressControl(param)
	if param is 1 then
		set enabled of button "update" of window "mainwindow" to false
		set enabled of button "cancel" of window "mainwindow" to false
		set uses threaded animation of progress indicator "progress" of window "mainwindow" to true
		tell progress indicator "progress" of window "mainwindow" to start
		tell window "mainwindow" to update
	else if param is 2 then
		tell progress indicator "progress" of window "mainwindow" to stop
		set enabled of button "cancel" of window "mainwindow" to true
		set enabled of button "update" of window "mainwindow" to true
	end if
end progressControl

on registerSettings()
	tell user defaults
		make new default entry at end of default entries with properties {name:"autostart", contents:false}
		make new default entry at end of default entries with properties {name:"autoquit", contents:false}
		make new default entry at end of default entries with properties {name:"defaultURL", contents:BWAgentDefaultURL}
		register
	end tell
end registerSettings

on readSettings()
	tell user defaults
		set defaultURL to (contents of default entry "defaultURL") as string
		set autostart to (contents of default entry "autostart") as boolean
		set autoquit to (contents of default entry "autoquit") as boolean
	end tell
	-- old standard URL was deprecated, so we convert it to new recommended URL.
	if defaultURL is "http://www.ff.iij4u.or.jp/~ch2/bbsmenu.html" then
		set defaultURL to BWAgentDefaultURL
	end if
end readSettings

on writeSettings()
	tell user defaults
		set contents of default entry "defaultURL" to (defaultURL as string)
		set contents of default entry "autostart" to autostart
		set contents of default entry "autoquit" to autoquit
	end tell
end writeSettings