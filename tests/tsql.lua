#!/usr/local/bin/lua

local sql = require"dado.sql"
print(sql._VERSION)

-- escape
assert (sql.escape([[a'b]]) == [[a''b]])
assert (sql.escape([[a"b]]) == [[a"b]])
local com_zero = "'abc\0def'"
assert (sql.escape(com_zero) == "''abcdef''", "Cannot escape \\0")
io.write"."

-- quote
assert (sql.quote([[a'b]]) == [['a''b']])
assert (sql.quote([[a\'b]]) == [['a\''b']])
assert (sql.quote([['b']]) == [['''b''']])
assert (sql.quote([[()'b'()]]) == [['()''b''()']])
assert (sql.quote([[(NULL)]]) == [['(NULL)']])
assert (sql.quote([[((NULL))]]) == [[((NULL))]])
assert (sql.quote([[(CURRENT_DATE)]]) == [['(CURRENT_DATE)']])
assert (sql.quote([[((CURRENT_DATE))]]) == [[((CURRENT_DATE))]])
assert (sql.quote([[(SIGLA/MALUCA)]]) == [['(SIGLA/MALUCA)']])
assert (sql.quote([[((SIGLA/MALUCA))]]) == [[((SIGLA/MALUCA))]])
assert (sql.quote([[(select col from tab where cond)]]) == [['(select col from tab where cond)']])
assert (sql.quote([[((select col from tab where cond))]]) == [[((select col from tab where cond))]])
assert (sql.quote([[(a comment inside parens should be quoted)]]) == [['(a comment inside parens should be quoted)']])
assert (sql.quote([[((a comment inside double-balanced-parens should NOT be quoted))]]) == [[((a comment inside double-balanced-parens should NOT be quoted))]])
assert (sql.quote(1) == 1)
assert (sql.quote("(1)") == "'(1)'")
assert (sql.quote("((1))") == "((1))")
assert (sql.quote(1.5) == 1.5)
assert (sql.quote("(1.5)") == "'(1.5)'")
assert (sql.quote("((1.5))") == "((1.5))")
assert (sql.quote("(1,2)") == "'(1,2)'")
assert (sql.quote("((1,2))") == "((1,2))")
assert (sql.quote("md5('123456')") == "'md5(''123456'')'")
assert (sql.quote("(md5('123456'))") == "'(md5(''123456''))'")
assert (sql.quote("((md5('123456')))") == "((md5('123456')))")
assert (sql.quote("a'b") == [['a''b']])
assert (sql.quote(com_zero) == [['''abcdef''']], "Cannot quote '\\0'")
assert (sql.quote(false) == false)
assert (sql.quote("(false)") == "'(false)'")
assert (sql.quote("((false))") == "((false))")
io.write"."

-- select
assert (sql.select("a", "t") == "select a from t")
assert (sql.select("a", "t", "w") == "select a from t where w")
assert (sql.select("a", "t", nil, "e") == "select a from t e")
assert (sql.select("a", "t", "w", "e") == "select a from t where w e")
io.write"."

-- insert
assert (sql.insert("t", { a = 1 }) == "insert into t (a) values (1)")
local stmt = sql.insert("t", { a = 1, b = "qw" })
assert (stmt == "insert into t (a,b) values (1,'qw')" or
        stmt == "insert into t (b,a) values ('qw',1)")
local stmt = sql.insert("t", { a = false, b = "qw" })
assert (stmt == "insert into t (a,b) values (false,'qw')" or
        stmt == "insert into t (b,a) values ('qw',false)")
io.write"."

-- update
assert (sql.update("t", { a = 1 }) == "update t set a=1")
assert (sql.update("t", { a = true }) == "update t set a=true")
local stmt = sql.update("t", { a = 1, b = "qw" })
assert (stmt == "update t set a=1,b='qw'")
io.write"."

-- delete
assert (sql.delete("t") == "delete from t")
assert (sql.delete("t", "a=1") == "delete from t where a=1")
io.write"."

-- simple AND expression
assert (sql.AND { a = 1, b = 2 } == "a=1 AND b=2")
local cond = sql.AND { a = 1, b = true }
assert (cond == "a=1 AND b=true" or cond == "b=true AND a = 1")
local sub = sql.subselect("id", "usuario", "nome ilike "..sql.quote"tomas%")
assert (sql.AND { id = sub } == [[id=((select id from usuario where nome ilike 'tomas%'))]], sql.AND { id = sub })
io.write"."

-- integer check
assert (sql.isinteger(1) == true, "Cannot detect number 1")
assert (sql.isinteger(0) == true, "Cannot detect number 0")
assert (sql.isinteger(-1) == true, "Cannot detect number -1")
assert (sql.isinteger(1e0) == true, "Cannot detect number 1e0")
assert (sql.isinteger"1" == true, "Cannot detect string with number 1")
assert (sql.isinteger"0" == true, "Cannot detect string with number 0")
assert (sql.isinteger"-1" == true, "Cannot detect string with number -1")
assert (sql.isinteger" 0 " == true, "Cannot detect string with number ' 0 '")
assert (sql.isinteger" -1 " == true, "Cannot detect string with number ' -1 '")
assert (sql.isinteger"3-1" == false, "Cannot reject string with expression '3-1'")
assert (sql.isinteger" 3 - 1 " == false, "Cannot reject string with expression ' 3 - 1 '")
assert (sql.isinteger"1e0" == false, "Cannot reject scientific notation 1e0")
assert (sql.isinteger"1e1" == false, "Cannot reject scientific notation 1e1")
assert (sql.isinteger"INF" == false, "Cannot reject non-representable number INF")
assert (sql.isinteger"NAN" == false, "Cannot reject non-representable number NAN")
assert (sql.isinteger(true) == false, "Cannot reject boolean true")
assert (sql.isinteger{} == false, "Cannot reject table value")
io.write"."

print" Ok!"
