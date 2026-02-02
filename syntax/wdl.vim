if exists("b:current_syntax")
  finish
endif

" Version declaration
syn keyword wdlVersion version

" Keywords - declarations
syn keyword wdlKeyword task workflow struct enum import nextgroup=wdlIdentifier skipwhite

" Keywords - blocks
syn keyword wdlBlock input output command runtime meta parameter_meta
syn keyword wdlBlock requirements hints

" Keywords - control flow
syn keyword wdlKeyword call scatter if then else

" Keywords - modifiers
syn keyword wdlKeyword as alias in

" Types
syn keyword wdlType String Int Float Boolean File Directory
syn keyword wdlType Array Map Pair Object None

" Constants
syn keyword wdlConstant true false null
syn keyword wdlConstant left right

" Identifiers (for task/workflow/struct names)
syn match wdlIdentifier /\<[A-Za-z][A-Za-z0-9_]*\>/ contained

" Numbers
syn match wdlNumber /\<\d\+\>/
syn match wdlNumber /\<\d\+\.\d*\%([eE][+-]\?\d\+\)\?\>/
syn match wdlNumber /\<0x[0-9a-fA-F]\+\>/
syn match wdlNumber /\<0[0-7]\+\>/

" Strings
syn region wdlString start=/"/ skip=/\\"/ end=/"/ contains=wdlEscape,wdlPlaceholder
syn region wdlString start=/'/ skip=/\\'/ end=/'/ contains=wdlEscape

" Heredoc command blocks
syn region wdlCommand start=/<<</ end=/>>>/ contains=wdlEscape,wdlPlaceholder
syn region wdlCommandBrace start=/command\s*{/ end=/}/ contains=wdlEscape,wdlPlaceholder

" Placeholders
syn region wdlPlaceholder start=/\~{/ end=/}/ contained contains=wdlPlaceholder
syn region wdlPlaceholder start=/\${/ end=/}/ contained contains=wdlPlaceholder

" Escape sequences
syn match wdlEscape /\\[\\nrt'\"~$]/ contained
syn match wdlEscape /\\[0-7]\{3}/ contained
syn match wdlEscape /\\x[0-9a-fA-F]\{2}/ contained
syn match wdlEscape /\\u[0-9a-fA-F]\{4}/ contained
syn match wdlEscape /\\U[0-9a-fA-F]\{8}/ contained

" Comments
syn match wdlComment /#.*$/

" Operators
syn match wdlOperator /[+\-*/%=<>!&|]/
syn match wdlOperator /==/
syn match wdlOperator /!=/
syn match wdlOperator /<=/
syn match wdlOperator />=/
syn match wdlOperator /&&/
syn match wdlOperator /||/

" Braces and brackets
syn match wdlBracket /[{}\[\]()]/

" Highlighting links
hi def link wdlVersion PreProc
hi def link wdlKeyword Keyword
hi def link wdlBlock Statement
hi def link wdlType Type
hi def link wdlConstant Constant
hi def link wdlIdentifier Function
hi def link wdlNumber Number
hi def link wdlString String
hi def link wdlCommand String
hi def link wdlCommandBrace String
hi def link wdlPlaceholder Special
hi def link wdlEscape SpecialChar
hi def link wdlComment Comment
hi def link wdlOperator Operator
hi def link wdlBracket Delimiter

let b:current_syntax = "wdl"
