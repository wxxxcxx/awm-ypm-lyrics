# YesPlayMusic desktop lyrics for AwesomeWM

## 依赖

 YesPlayMusic master 分支最新版本

## 安装

``` sh
git clone https://github.com/meetcw/awm-ypm-lyrics.git ~/.config/awesome/awm-ypm-lyrics

```

编辑 AwesomeWM 配置文件

``` lua
local wibox = require('wibox')
local ypm = require('awm-ypm-lyrics')

ypm:setup{
     {
        id = 'current_lyrics',
        markup = '',
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    },
    {
        id = 'next_lyrics',
        markup = '',
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.vertical
}

client.connect_signal(
    'manage',
    function(c)
        if c.class == 'yesplaymusic' then
            ypm:start()
        end
    end
)

client.connect_signal(
    'unmanage',
    function(c)
        if c.class == 'yesplaymusic' then
            ypm:stop()
        end
    end
)

```

