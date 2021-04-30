# YesPlayMusic desktop lyric for AwesomeWM

![ScreenShot](./screenshot.png)

## 依赖

 [YesPlayMusic](https://github.com/qier222/YesPlayMusic) master 分支最新版本

## 安装

``` sh
# Clone 本项目到 AwesomeWM 配置目录
git clone https://github.com/meetcw/awm-ypm-lyrics.git ~/.config/awesome/awm-ypm-lyrics

```

编辑 AwesomeWM 配置文件

``` lua
local wibox = require('wibox')
local ypm = require('awm-ypm-lyrics')

-- 设置显示歌词的 Widget
ypm:setup{
     {
        id = 'current_lyric',
        markup = '',
        align = 'center',
        valign = 'center',
        font = font,
        widget = wibox.widget.textbox
    },
    {
        id = 'next_lyric',
        markup = '',
        align = 'center',
        valign = 'center',
        font = font,
        widget = wibox.widget.textbox
    },
    layout = wibox.layout.fixed.vertical
}

-- 跟随 YesPlayMusic 的开启和关闭，显示隐藏歌词
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

