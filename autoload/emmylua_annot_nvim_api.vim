scriptencoding utf-8

let s:plugin_dir = expand('<sfile>:h:h')

" Save directory path
let g:emmylua_annot_nvim_api#meta_path = get(g:,
\ 'emmylua_annot_nvim_api#meta_path', stdpath("config") .. '/.emmylua_annot_nvim_api/meta')


let s:NVIM_TYPE_MAP = {
\  'Integer': 'number',
\  'Float': 'number',
\  'String': 'string',
\  'Boolean': 'boolean',
\  'Array': 'any[]',
\  'Dictionary': 'table<string, any>',
\  'Object': 'table<string, any>',
\  'Buffer': 'Buffer',
\  'Window': 'Window',
\  'Tabpage': 'Tabpage',
\  'LuaRef': 'function',
\  'ArrayOf(String)': 'string[]',
\  'ArrayOf(Integer)': 'number[]',
\  'ArrayOf(Integer, 2)': 'number[]',
\  'ArrayOf(Dictionary)': 'table<string, any>[]',
\  'ArrayOf(Window)': 'Window[]',
\  'ArrayOf(Buffer)': 'Buffer[]',
\  'ArrayOf(Tabpage)': 'Tabpage[]',
\}

function! emmylua_annot_nvim_api#get_meta_data_lines() abort
  " No need for deprecation
  let l:functions = filter(api_info().functions, '!has_key(v:val, "deprecated_since")')

  let l:res = [
  \ '---@meta',
  \ '',
  \ '---@alias Buffer number',
  \ '---@alias Window number',
  \ '---@alias Tabpage number',
  \ '',
  \ '---@class vim',
  \ 'vim = {}',
  \ '',
  \ 'vim.api = {}',
  \ '',
  \]

  for l:func in l:functions
    " @param
    for l:param in l:func.parameters
      let [l:type, l:name] = l:param
      call add(l:res, printf('---@param %s %s', l:name, s:NVIM_TYPE_MAP[l:type]))
    endfor

    " @return
    if get(l:func, 'return_type', 'void') !=# 'void'
      call add(l:res, printf("---@return %s", s:NVIM_TYPE_MAP[l:func.return_type]))
    endif

    " signature
    let l:params = join(map(deepcopy(l:func.parameters), 'v:val[1]'), ', ')
    call add(l:res, printf("function vim.api.%s(%s) end", l:func.name, l:params))

    call add(l:res, '')
  endfor

  return l:res
endfunction

" generate meta file
function! emmylua_annot_nvim_api#gen_meta_file() abort
  let l:dir = g:emmylua_annot_nvim_api#meta_path .. '/LuaJIT en-us/'
  " Make directory if not exists
  if !isdirectory(l:dir)
    call mkdir(l:dir, 'p')
  endif

  " TODO: version と lang を動的にする
  let l:fpath = l:dir .. '/vim.lua'
  call delete(l:fpath)
  call writefile(emmylua_annot_nvim_api#get_meta_data_lines(), l:fpath)
endfunction

function! emmylua_annot_nvim_api#get_meta_path() abort
  return g:emmylua_annot_nvim_api#meta_path
endfunction
