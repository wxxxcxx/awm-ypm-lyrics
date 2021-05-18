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
            local data = gears.protected_call.call(json.decode, out)
            if data then
                if data.lrc then
                    local lrc_text = data.lrc.lyric
                    module.current_lyrics = lyrics.convert_lyrics(lrc_text)
                end
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
            local data = gears.protected_call.call(json.decode, out)
            if data then
                local id = data.currentTrack.id
                local progress = data.progress * 1000
                if callback then
                    callback(id, progress)
                end
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
                current_lyric = module.current_lyrics:current(progress)

                next_lyric = module.current_lyrics:next(progress)
            end

            local textbox_list = module.lyrics_wibox:get_children_by_id('current_lyric')
            for i, textbox in ipairs(textbox_list) do
                textbox.markup = string.format(' <b>%s</b> ', current_lyric)
            end
            local textbox_list = module.lyrics_wibox:get_children_by_id('next_lyric')
            for i, textbox in ipairs(textbox_list) do
                textbox.markup = string.format(' <b>%s</b> ', next_lyric)
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

function module:setup(box)
    module.lyrics_wibox = box
end
function module:start()
    if module.lyrics_wibox then
        timer:start()
    end
end

function module:stop()
    if module.lyrics_wibox then
        timer:stop()
    end
end

return module
