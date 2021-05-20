local lyrics = require('awm-ypm-lyrics.lyrics')

local file = assert(io.open('awm-ypm-lyrics/test.lrc', 'r'))
local text = file:read('*all')

local ly = lyrics.convert_lyrics(text)
print(ly:current(221870))