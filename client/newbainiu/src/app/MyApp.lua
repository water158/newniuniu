require("cocos.init")
require("framework.init")
require("app.config")
require("app.service.WebService")
require("app.common.Localize")
require("app.common.events")
require("app.service.GameService")
require("app.service.WebService")
require("app.service.PayService")
require("app.utils.PlatformUtils")
require("app.data.GameData")
require("framework.ql.network.WebSockets")


function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
    --require("config")
    if DEBUG > 0 then
    	local file = io.open(cc.FileUtils:getInstance():getWritablePath().."error.log", "a+b")
	    if file then
	        file:write(os.date().."   "..tostring(errorMessage).."\n"..debug.traceback("", 2).."\n")
	        io.close(file)
	    end
	else
        --报告问题
        reportError(tostring(errorMessage).."\n"..debug.traceback("", 2))
    end
end

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end
--onEnter
function MyApp:run()

	cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(1280, 720, 0)
    cc.FileUtils:getInstance():addSearchPath(device.writablePath.."res/")

    cc.FileUtils:getInstance():addSearchPath("res/")

    math.randomseed(os.time())
   
   self:enterScene("LoadingScene")

end

return MyApp
