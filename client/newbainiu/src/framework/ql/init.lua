--
-- Author: Carl
-- Date: 2015-07-08 17:13:58
--

MAX_ZORDER = 2147483647

ql = ql or {}
ql.mvc = import(".mvc.init")
ql.net = import(".network.init")
ql.custom = import(".custom.init")
ql.utils = import(".utils.init")

import(".EventDispatcher")