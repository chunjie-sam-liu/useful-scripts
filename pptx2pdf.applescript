#!/usr/bin/osascript

on run argv
	-- 1. Help / Usage Information
	set usage to "PowerPoint to PDF Converter CLI
Usage: pptx2pdf.applescript [options]

Options:
  -p [files...]    Provide one or more .pptx files to convert.
  -d [directory]   Provide a directory; converts all .pptx files inside.
  -h, --help       Show this help message.

Examples:
  pptx2pdf.applescript -p presentation1.pptx presentation2.pptx
  pptx2pdf.applescript -d .
  pptx2pdf.applescript -d /Users/username/Documents
  pptx2pdf.applescript -p report.pptx -d ./backups"

	-- If no arguments or help requested
	if (count of argv) is 0 or (argv contains "-h") or (argv contains "--help") then
		return usage
	end if

	set fileList to {}
	set dirList to {}

	-- 2. Argument Parsing
	set i to 1
	repeat while i ≤ (count of argv)
		set currentArg to item i of argv
		if currentArg is "-p" then
			set i to i + 1
			repeat while i ≤ (count of argv) and (item i of argv) does not start with "-"
				set end of fileList to resolvePath(item i of argv)
				set i to i + 1
			end repeat
		else if currentArg is "-d" then
			set i to i + 1
			if i ≤ (count of argv) then
				set end of dirList to resolvePath(item i of argv)
				set i to i + 1
			end if
		else
			set i to i + 1
		end if
	end repeat

	-- 3. Gather files from directories
	tell application "System Events"
		repeat with theDir in dirList
			set theDir to theDir as string
			if exists folder theDir then
				set folderItems to every file of folder theDir
				repeat with theItem in folderItems
					set thePath to POSIX path of theItem
					set theName to name of theItem
					-- Filter for PPT/PPTX and ignore hidden/temp files (starting with ~$)
					if (thePath ends with ".pptx" or thePath ends with ".ppt") and (theName does not start with "~$") then
						set end of fileList to thePath
					end if
				end repeat
			else
				-- Log to stderr if directory not found
				log "Directory not found: " & theDir
			end if -- FIXED: Was 'end try' previously, causing your error
		end repeat
	end tell

	-- 4. Process the conversion queue
	if (count of fileList) is 0 then
		return "No valid PowerPoint files found to convert."
	end if

	set successCount to 0
	set errorList to {}

	tell application "Microsoft PowerPoint"
		launch
		activate

		repeat with currentFile in fileList
			try
				set outPath to my getPDFPath(currentFile)
				open (POSIX file currentFile)

				-- Wait for presentation to open (max 5 seconds)
				set waitCount to 0
				repeat until (exists active presentation) or waitCount > 50
					delay 0.1
					set waitCount to waitCount + 1
				end repeat

				if (exists active presentation) then
					save active presentation in (POSIX file outPath) as save as PDF
					close active presentation saving no
					set successCount to successCount + 1
				else
					set end of errorList to "Timeout/Failed to open: " & currentFile
				end if
			on error errMsg
				set end of errorList to "Error with " & currentFile & ": " & errMsg
				try
					if (exists active presentation) then close active presentation saving no
				end try
			end try
		end repeat
	end tell

	-- 5. Final Report
	set resultMsg to "Finished! Successfully converted " & successCount & " files."
	if (count of errorList) > 0 then
		set AppleScript's text item delimiters to "\n"
		set resultMsg to resultMsg & "\n\nErrors encountered:\n" & (errorList as string)
		set AppleScript's text item delimiters to ""
	end if
	return resultMsg
end run

-- Helper: Resolve paths, handle '.', and expand tildes
on resolvePath(thePath)
	set pwd to system attribute "PWD"
	if thePath is "." then
		set thePath to pwd
	else if thePath starts with "./" then
		set thePath to pwd & text 2 thru -1 of thePath
	else if thePath starts with "~" then
		set thePath to (POSIX path of (path to home folder)) & text 2 thru -1 of thePath
	else if thePath does not start with "/" then
		set thePath to pwd & "/" & thePath
	end if

	-- Clean up any trailing /. or //
	if thePath ends with "/." then set thePath to text 1 thru -3 of thePath
	if thePath ends with "/" then set thePath to text 1 thru -2 of thePath

	return thePath
end resolvePath

-- Helper: Generate output PDF path
on getPDFPath(posixPath)
	set AppleScript's text item delimiters to "."
	set pathParts to text items of posixPath
	if (count of pathParts) > 1 then
		set last item of pathParts to "pdf"
		set pdfPath to pathParts as string
	else
		set pdfPath to posixPath & ".pdf"
	end if
	set AppleScript's text item delimiters to ""
	return pdfPath
end getPDFPath