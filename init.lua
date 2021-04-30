local wibox = require('wibox')
local spawn = require('awful.spawn')
local lyrics = require('awm-ypm-lyrics.lyrics')
local json = require('awm-ypm-lyrics.json')

local module = {
    current_id = nil,
    current_lyrics = nil,
    current_tlyrics = nil
}

function get_lyrics(id)
    spawn.easy_async_with_shell(
        string.format('curl -s "http://127.0.0.1:10754/lyric?id=%s"', id),
        function(out, error)
            local data = json.decode(out)
            if data.lrc then
                local lrc_text = data.lrc.lyric
                module.current_lyrics = lyrics.convert_lyrics(lrc_text)
            end
            -- if data.tlyric then
            --     local tlrc_text = data.tlyric.lyric
            --     current_tlyrics=lyrics.convert_lyrics(tlrc_text)
            -- end
        end
    )
end

function get_current(callback)
    --GET http://127.0.0.1:27232/player
    spawn.easy_async_with_shell(
        'curl -s "http://127.0.0.1:27232/player"',
        function(out)
            local data = json.decode(out)
            local id = data.currentTrack.id
            local progress = data.progress * 1000
            if callback then
                callback(id, progress)
            end
        end
    )
end

function update_lyrics()
    get_current(
        function(id, progress)
            progress = progress + 200
            if module.current_id ~= id then
                module.current_id = id
                module.current_lyrics = nil
                module.current_tlyrics = nil
                get_lyrics(id)
            end
            local current_lyrics = ''
            local next_lyrics = ''
            if module.current_lyrics then
                -- print()
                current_lyrics = module.current_lyrics:current(progress)
                next_lyrics = module.current_lyrics:next(progress)
            end

            local textbox_list = module.lyrics_wibox:get_children_by_id('current_lyrics')
            for i, textbox in ipairs(textbox_list) do
                textbox.markup = string.format('<b>%s</b>', current_lyrics)
            end
            local shadow_textbox_list = module.lyrics_wibox:get_children_by_id('current_lyrics_shadow')
            for i, shadow_textbox in ipairs(shadow_textbox_list) do
                shadow_textbox.markup = string.format('<b>%s</b>', current_lyrics)
            end

            local textbox_list = module.lyrics_wibox:get_children_by_id('next_lyrics')
            for i, textbox in ipairs(textbox_list) do
                textbox.markup = string.format('<b>%s</b>', next_lyrics)
            end
            local shadow_textbox_list = module.lyrics_wibox:get_children_by_id('next_lyrics_shadow')
            for i, shadow_textbox in ipairs(shadow_textbox_list) do
                shadow_textbox.markup = string.format('<b>%s</b>', next_lyrics)
            end
        end
    )
end

local timer =
    gears.timer {
    timeout = 0.5,
    call_now = false,
    autostart = false,
    callback = update_lyrics
}

module.lyrics_wibox =
    wibox {
    screen = screen.primary,
    width = screen.primary.workarea.width,
    height = screen.primary.workarea.height,
    x = 0,
    y = 0,
    bg = '#00000000',
    visible = true,
    ontop = true,
    type = 'utility',
    input_passthrough = true
}


function module:setup(widget)
    module.lyrics_wibox:setup(widget)
end
function module:start()
    timer:start()
    module.lyrics_wibox.visible = true
end

function module:stop()
    timer:stop()
    module.lyrics_wibox.visible = false
end

return module
