function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

APPPATH = 'app.'
SYSPATH = 'system.'
LIBPATH = 'libs.'

local function main()
	require(SYSPATH .. 'yi')

	Yi.import('init')
	Yi:init{
		log = true,
		lang = 'zh_cn'
	}
	app.run()
end

xpcall(main, __G__TRACKBACK__)

-- avoid memory leak
-- collectgarbage("collect")
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)