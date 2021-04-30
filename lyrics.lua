local module = {}
local function lyrics_time_to_millisecond(time)
    local m, s, ps = string.match(time, '(%d-):(%d-)%.(%d+)')
    return m * 60 * 1000 + s * 1000 + ps * 10
end

function module.convert_lyrics(text)
    local lyrics = {}
    lyrics.timeline = {}
    for row in string.gmatch(text, '(.-)%c') do
        -- print("row: "..row)
        local content = string.match(row, '%[%d-:%d-%.%d+%](.*)')
        for time in string.gmatch(row, '%[(%d-:%d-%.%d+)%]') do
            local ms = lyrics_time_to_millisecond(time)
            table.insert(
                lyrics.timeline,
                {
                    time = ms,
                    content = content
                }
            )
        end
    end
    table.sort(
        lyrics.timeline,
        function(a, b)
            return a.time < b.time
        end
    )

    function lyrics:get(time)
        time = time + 500
        for i, item in ipairs(self.timeline) do
            if item.time > time then
                return i > 1 and self.timeline[i - 1].content or item.content
            end
        end
        return ''
    end
    return lyrics
end

return module
-- local file = assert(io.open('test.lrc', 'r'))
-- local text = file:read('*all')

-- local ly = convert_lyrics(text)
-- ly:get(1000)
