" Vim completion script
" Language:	CSS
" Maintainer:	erjun

    let s:values=[]
    let dataFile = $HOME.'/.vim/bundle/complete/json/css.json'
    let s:data=ParseJSON(readfile(dataFile)[0])
    for key in keys(s:data)
        call add(s:values,key)
    endfor
fu! AddComplete(res,m,type)
    let keyAfter = ''
    if a:type == 'key'
        let keyAfter = ':'
    elseif a:type == 'atrule2'
        let keyAfter = ' '
    endif

    let word = split(a:m,'|')
    let info = get(word,1,'')
    let menu = get(word,2,'all')

    "call add(a:res,{'word': word[0] . keyAfter,'info':info})
    call add(a:res,{'word': word[0] . keyAfter,'info':info,'menu':menu})
endfu
function! csscomplete#CompleteCSS(findstart, base)
if a:findstart
	" 检查整行
	let line = getline('.') "光标所在行
	let start = col('.') - 1 "光标前1个字符
	let compl_begin = col('.') - 2 "光标前2个字符
	while start >= 0 && line[start - 1] =~ '\%(\k\|-\)'
		let start -= 1
	endwhile
	let b:compl_context = line[0:compl_begin]
	return start
endif

" There are few chars important for context:
" ^ ; : { } /* */
" Where ^ is start of line and /* */ are comment borders
" Depending on their relative position to cursor we will know what should
" be completed. 
" 1. if nearest are ^ or { or ; current word is property
" 2. if : it is value (with exception of pseudo things)
" 3. if } we are outside of css definitions
" 4. for comments ignoring is be the easiest but assume they are the same
"    as 1. 
" 5. if @ complete at-rule
" 6. if ! complete important
if exists("b:compl_context")
	let line = b:compl_context
	unlet! b:compl_context
else
	let line = a:base
endif

let res = []
let res2 = []
let borders = {}

" Check last occurrence of sequence

let openbrace  = strridx(line, '{')
let closebrace = strridx(line, '}')
let colon      = strridx(line, ':')
let semicolon  = strridx(line, ';')
let opencomm   = strridx(line, '/*')
let closecomm  = strridx(line, '*/')
let style      = strridx(line, 'style\s*=')
let atrule     = strridx(line, '@')
let exclam     = strridx(line, '!')

if openbrace > -1
	let borders[openbrace] = "openbrace"
endif
if closebrace > -1
	let borders[closebrace] = "closebrace"
endif
if colon > -1
	let borders[colon] = "colon"
endif
if semicolon > -1
	let borders[semicolon] = "semicolon"
endif
if opencomm > -1
	let borders[opencomm] = "opencomm"
endif
if closecomm > -1
	let borders[closecomm] = "closecomm"
endif
if style > -1
	let borders[style] = "style"
endif
if atrule > -1
	let borders[atrule] = "atrule"
endif
if exclam > -1
	let borders[exclam] = "exclam"
endif

"key
if len(borders) == 0 || borders[max(keys(borders))] =~ '^\%(openbrace\|semicolon\|opencomm\|closecomm\|style\)$'
	" Complete properties

	let entered_property = matchstr(line, '.\{-}\zs[a-zA-Z-]*$')

	for m in s:values
		if m =~? '^'.entered_property
            "if exists()
            call AddComplete(res,m,'key')
		elseif m =~? entered_property
            call AddComplete(res2,m,'key')
		endif
	endfor

	return res + res2

"value
elseif borders[max(keys(borders))] == 'colon'
	"  获取名称的属性
	let prop = tolower(matchstr(line, '\zs[a-zA-Z-]*\ze\s*:[^:]\{-}$'))
    for key in keys(s:data)
        if prop == key
            let values = s:data[key]
            break
        endif
    endfor

    if exists('values') == 0
        "let values = [line]
        let element = tolower(matchstr(line, '\zs[a-zA-Z1-6]*\ze:[^:[:space:]]\{-}$'))
        if stridx(',a,abbr,acronym,address,area,b,base,bdo,big,blockquote,body,br,button,caption,cite,code,col,colgroup,dd,del,dfn,div,dl,dt,em,fieldset,form,head,h1,h2,h3,h4,h5,h6,hr,html,i,img,input,ins,kbd,label,legend,li,link,map,meta,noscript,object,ol,optgroup,option,p,param,pre,q,samp,script,select,small,span,strong,style,sub,sup,table,tbody,td,textarea,tfoot,th,thead,title,tr,tt,ul,var,', ','.element.',') > -1
            let values = ["first-child", "link", "visited", "hover", "active", "focus", "lang", "first-line", "first-letter", "before", "after"]
        else
            return []
        endif
    endif
	" Complete values
	let entered_value = matchstr(line, '.\{-}\zs[a-zA-Z0-9#,.(_-]*$')

	for m in values
		if m =~? '^'.entered_value
            call AddComplete(res,m,'colon')
		elseif m =~? entered_value
            call AddComplete(res2,m,'colon')
		endif
	endfor

	return res + res2

elseif borders[max(keys(borders))] == 'closebrace'

	return []

elseif borders[max(keys(borders))] == 'exclam'

	" Complete values
	let entered_imp = matchstr(line, '.\{-}!\s*\zs[a-zA-Z ]*$')

	let values = ["important"]

	for m in values
		if m =~? '^'.entered_imp
            call AddComplete(res,m,'closebrace')
		endif
	endfor

	return res

elseif borders[max(keys(borders))] == 'atrule'

	let afterat = matchstr(line, '.*@\zs.*')

	if afterat =~ '\s'

		let atrulename = matchstr(line, '.*@\zs[a-zA-Z-]\+\ze')

		if atrulename == 'media'
			let values = ["screen", "tty", "tv", "projection", "handheld", "print", "braille", "aural", "all"]

			let entered_atruleafter = matchstr(line, '.*@media\s\+\zs.*$')

		elseif atrulename == 'import'
			let entered_atruleafter = matchstr(line, '.*@import\s\+\zs.*$')

			if entered_atruleafter =~ "^[\"']"
				let filestart = matchstr(entered_atruleafter, '^.\zs.*')
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"\"".v:val')

			elseif entered_atruleafter =~ "^url("
				let filestart = matchstr(entered_atruleafter, "^url([\"']\\?\\zs.*")
				let files = split(glob(filestart.'*'), '\n')
				let values = map(copy(files), '"url(".v:val')
				
			else
				let values = ['"', 'url(']

			endif

		else
			return []

		endif

		for m in values
			if m =~? '^'.entered_atruleafter
                call AddComplete(res,m,'atrule')
			elseif m =~? entered_atruleafter
                call AddComplete(res2,m,'atrule')
			endif
		endfor

		return res + res2

	endif

	let values = ["charset", "page", "media", "import", "font-face"]

	let entered_atrule = matchstr(line, '.*@\zs[a-zA-Z-]*$')

	for m in values
		if m =~? '^'.entered_atrule
            call AddComplete(res,m,'atrule2')
			"call add(res, m .' ')
		elseif m =~? entered_atrule
            call AddComplete(res2,m,'atrule2')
		endif
	endfor

	return res + res2

endif

return []

endfunction
