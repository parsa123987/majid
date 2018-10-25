-- in the name of god
-- start

package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
.. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

_Config = dofile('./Config.lua')
json = dofile('./data/JSON.lua')
ltn12 = require "ltn12"
utf8 = require "lua-utf8"
serpent = require "serpent"
JSON = require "dkjson"
URL = require "socket.url"
http = require "socket.http"
https = require "ssl.https"
socket = require "socket"
redis = require "redis"
redis = redis.connect('127.0.0.1', 6379)
splitredis = redis:select(1) -- Redis Split
Usersudo = _Config.Usersudo
logs = _Config.logs
Mehdi = _Config.Mehdi
ReacTanceSudos = _Config.ReacTanceSudos
ReacTance_id = _Config.ReacTance_id -- ایدی ربات
ReaTanceToken = _Config.ReaTanceToken
channel = _Config.channel
support = _Config.support
botusername = _Config.botusername
http.TIMEOUT = 5


color = {
red = {31, 41},
green = {32, 42},
yellow = {33, 43},
blue = {34, 44},
magenta = {35, 45},
cyan = {36, 46},
white = {37, 47}
}


function vardump(value)
print '\n-------------------------------------------------------------- START'
print(serpent.block(value, {comment=false}))
print '--------------------------------------------------------------- STOP\n'
end

function sleep(n)
os.execute("sleep".. tonumber(n))
end

function dl_cb(arg, data)
end

function is_sudo(msg)
local var = false
for k,v in pairs(ReacTanceSudos) do
if msg.sender_user_id == v then
var = true
end
end
return var
end

function is_admin(msg)
local hash = redis:sismember('admins', msg.sender_user_id)
if hash or is_sudo(msg)  then
return true
else
return false
end
end

function is_owner(msg)
local hash = redis:sismember('owners'..msg.chat_id, msg.sender_user_id)
if hash or  is_sudo(msg) or is_admin(msg) then
return true
else
return false
end
end

function is_mod(msg)
local hash = redis:sismember('mods'..msg.chat_id, msg.sender_user_id)
if hash or  is_sudo(msg) or is_admin(msg) or is_owner(msg) then
return true
else
return false
end
end

function is_vip(msg)
local hash = redis:sismember('vips'..msg.chat_id, msg.sender_user_id)
if hash or is_sudo(msg) or is_admin(msg) or is_owner(msg) or is_mod(msg) then
return true
else
return false
end
end

function is_banned(chat, user)
local hash = redis:sismember('banned'..chat, user)
if hash then
return true
else
return false
end
end

function is_gban(chat, user)
local hash = redis:sismember('gbaned', user)
if hash then
return true
else
return false
end
end

function is_muted(chat, user)
local hash = redis:sismember('mutes'..chat, user)
if hash then
return true
else
return false
end
end

function priv(chat, user)
local khash = redis:sismember('admins',user)
local ohash = redis:sismember('owners'..chat, user)
local mhash = redis:sismember('mods'..chat, user)
local vhash = redis:sismember('vips'..chat, user)
if tonumber(ReacTanceSudos) == tonumber(user) or khash or mhash or ohash or vhash then
return true
else
return false
end
end

function Force(msg)
if redis:get("force") then
local url  = https.request('https://api.telegram.org/bot'..ReaTanceToken..'/getchatmember?chat_id='..channel..'&user_id='..msg.sender_user_id)
data = json:decode(url)
local forcestatus = true
if not data.ok then
forcestatus = sendText(msg.chat_id, msg.id, '<i>• کاربر گرامی برای حمایت از ما و اطلاع از اخبار ربات ابتدا در کانال تیم عضو شوید سپس از دستورات ربات استفاده کنید !</i>\n\n• Ch : '..channel..'', 'html')
elseif (data.result.status == "left" or data.result.status == "kicked") then
forcestatus = sendText(msg.chat_id, msg.id, '<i>• کاربر گرامی برای حمایت از ما و اطلاع از اخبار ربات ابتدا در کانال تیم عضو شوید سپس از دستورات ربات استفاده کنید !</i>\n\n• Ch : '..channel..'', 'html')
end
return forcestatus
else
return true
end
end

function is_filter(msg,value)
local list = redis:smembers('filters'..msg.chat_id)
var = false
for i=1, #list do
if value:match(list[i]) then
var = true
end
end
return var
end

function UpTimeEn()
local uptime = io.popen("uptime"):read("*all")
days = uptime:match("up %d+")
hours = uptime:match("%d+:")
minutes = uptime:match(":%d+,")
sec = uptime:match(":%d+ up")
if hours then
hours = hours
else
hours = ""
end
if days then
days = days
else
days = ""
end
if minutes then
minutes = minutes
else
minutes = ""
end
days = days:gsub("up", "")
local a_ = string.match(days, "%d+")
local b_ = string.match(hours, "%d+")
local c_ = string.match(minutes, "%d+")
local d_ = string.match(sec, "%d+")
if a_ then
a = a_
else
a = 0
end
if b_ then
b = b_
else
b = 0
end
if c_ then
c = c_
else
c = 0
end
if d_ then
d = d_
else
d = 0
end
return a..' d '..b..' h '..c..' m '..d..' s'
end

function getParse(parse_mode)
local P = {}
if parse_mode then
local mode = parse_mode:lower()
if mode == 'markdown' or mode == 'md' then
P._ = 'textParseModeMarkdown'
elseif mode == 'html' then
P._ = 'textParseModeHTML'
end
end
return P
end

function getChatId(chat_id)
local chat = {}
local chat_id = tostring(chat_id)
if chat_id:match('^-100') then
local channel_id = chat_id:gsub('-100', '')
chat = {id = channel_id, type = 'channel'}
else
local group_id = chat_id:gsub('-', '')
chat = {id = group_id, type = 'group'}
end
return chat
end

function sendText(chat_id,msg,text, parse)
assert(tdbot_function ({_ = "sendMessage",chat_id = chat_id,reply_to_message_id = msg,disable_notification = 0,from_background = 1,reply_markup = nil,input_message_content = {_ = "inputMessageText",text = text, disable_web_page_preview = 1, clear_draft = 0,parse_mode = getParse(parse),entities = {}}}, dl_cb, nil))
end

function getChatHistory(chat_id, from_message_id, offset, limit,cb)
assert (tdbot_function ({_ = "getChatHistory",chat_id = chat_id,from_message_id = from_message_id,offset = offset,limit = limit}, cb, nil))
end

function getUser(user_id, cb)
assert (tdbot_function ({_ = 'getUser',user_id = user_id}, cb, nil))
end

function getUserFull(user_id,cb)
assert (tdbot_function ({_ = "getUserFull",user_id = user_id}, cb, nil))
end

function getChat(chatid,cb)
assert (tdbot_function ({_ = 'getChat',chat_id = chatid}, cb, nil))
end

function getUserProfilePhotos(userid, off, lim, callback, data)
assert (tdbot_function ({_ = 'getUserProfilePhotos',user_id = userid,offset = off,limit = lim}, callback or dl_cb, data))
end

function Pin(channelid, messageid)
assert (tdbot_function ({_ = "pinChannelMessage",channel_id = getChatId(channelid).id,message_id = messageid,}, dl_cb, nil))
end

function unpin(channelid)
assert (tdbot_function ({_ = 'unpinChannelMessage',channel_id = getChatId(channelid).id}, dl_cb, nil))
end

function exportChatInviteLink(chatid)
assert (tdbot_function ({_ = 'exportChatInviteLink',chat_id = chatid}, dl_cb, nil))
end

function getChannelMembers(channelid, mbrfilter, off, limit, cb)
if not limit or limit > 200 then
limit = 200
end
assert (tdbot_function ({_ = 'getChannelMembers',channel_id = getChatId(channelid).id,filter = {_ = 'channelMembersFilter' .. mbrfilter,},offset = off,limit = limit}, cb, nil))
end

function forward(chat_id, from_chat_id, message_id, from_background)
assert (tdbot_function ({_ = "forwardMessages",chat_id = chat_id,from_chat_id = from_chat_id,message_ids = message_id,disable_notification = 0,from_background = from_background}, dl_cb, nil))
end

function getMessage(chat_id, message_id,cb)
assert (tdbot_function ({_ = "getMessage",chat_id = chat_id,message_id = message_id}, cb, nil))
end

function Left(chat_id, user_id, s)
assert (tdbot_function ({_ = "changeChatMemberStatus",chat_id = chat_id,user_id = user_id,status = {_ = "chatMemberStatus" ..s},}, dl_cb, nil))
end

function deleteMessages(chat_id, message_ids)
assert (tdbot_function ({_= "deleteMessages",chat_id = chat_id,message_ids = message_ids}, dl_cb, nil))
end

function searchPublicChat(username,cb)
assert (tdbot_function ({_ = "searchPublicChat",username = username}, cb, nil))
end

function KickUser(chat_id, user_id)
assert (tdbot_function ({_ = "changeChatMemberStatus",chat_id = chat_id,user_id = user_id,status = {_ = "chatMemberStatusBanned"},}, dl_cb, nil))
end

function getChannelFull(chat_id, cb)
assert (tdbot_function ({_ = 'getChannelFull',channel_id = getChatId(chat_id).id}, cb, nil))
end

function RemoveFromBanList(chat_id, user_id)
assert (tdbot_function ({_ = "changeChatMemberStatus",chat_id = chat_id,user_id = user_id,status = {_ = "chatMemberStatus" .."Left"},}, dl_cb, nil))
end

function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
assert (tdbot_function ({_= "sendMessage",chat_id = chat_id,reply_to_message_id = reply_to_message_id,disable_notification = disable_notification,from_background = from_background,reply_markup = reply_markup,input_message_content = {_ = "inputMessagePhoto",photo = getInputFile(photo),added_sticker_file_ids = {},width = 0,height = 0,caption = caption.."\n"},}, dl_cb, nil))
end

function sendDocument(chat_id, reply_to_message_id, document, caption)
assert (tdbot_function ({_= "sendMessage",chat_id = chat_id,reply_to_message_id = reply_to_message_id,disable_notification = 0,from_background = true,reply_markup = nil,input_message_content = {_ = 'inputMessageDocument',document = getInputFile(document),caption = tostring(caption)},}, dl_cb, nil))
end

function SendMetion(chat_id, user_id, msg_id, text, offset, length)
assert (tdbot_function ({_ = "sendMessage",chat_id = chat_id,reply_to_message_id = msg_id,disable_notification = 0,from_background = true,reply_markup = nil,input_message_content = {_ = "inputMessageText",text = text,disable_web_page_preview = 1,clear_draft = false,entities = {[0] = {offset =  offset,length = length,_ = "textEntity",type = {user_id = user_id, _ = "textEntityTypeMentionName"}}}}}, dl_cb, nil))
end

function sendSticker(chat_id, reply_to_message_id, sticker_file)
assert (tdbot_function ({_= "sendMessage",chat_id = chat_id,reply_to_message_id = reply_to_message_id,disable_notification = 0,from_background = true,reply_markup = nil,input_message_content = {_ = 'inputMessageSticker',sticker = getInputFile(sticker_file),width = 0,height = 0},}, dl_cb, nil))
end

function getInputFile(file, conversion_str, expectedsize)
local input = tostring(file)
local infile = {}
if (conversion_str and expectedsize) then
infile = {_ = 'inputFileGenerated',original_path = tostring(file),conversion = tostring(conversion_str),expected_size = expectedsize}
else
if input:match('/') then
infile = {_ = 'inputFileLocal', path = file}
elseif input:match('^%d+$') then
infile = {_ = 'inputFileId', id = file}
else
infile = {_ = 'inputFilePersistentId', persistent_id = file}
end
end
return infile
end

function okname(name)
txt = name
if txt then
if txt:match('_') then
txt = txt:gsub('_','')
elseif txt:match('*') then
txt = txt:gsub('*','')
elseif txt:match('`') then
txt = txt:gsub('`','')
elseif txt:match('#') then
txt = txt:gsub('#','')
elseif txt:match('@') then
txt = txt:gsub('@','')
elseif txt:match('\n') then
txt = txt:gsub('\n','')
end
return txt
end
end

function writefile(filename, input)
local file = io.open(filename, "w")
file:write(input)
file:flush()
file:close()
return true
end

function saveFile(url, file_name)
local respbody = {}
local options = {
url = url,
sink = ltn12.sink.table(respbody),
redirect = true
}
local response = nil
if url:match('^https') then
options.redirect = false
response = {https.request(options)}
else
response = {http.request(options)}
end
local code = response[2]
local headers = response[3]
local status = response[4]
if code ~= 200 then return nil end
file_name = file_name or get_http_file_name(url, headers)
local file_path = "./"..file_name
file = io.open(file_path, "w+")
file:write(table.concat(respbody))
file:close()
return file_path
end

function muteres(chat_id, user_id, Restricted, right)
local chat_member_status = {}
if Restricted == 'Restricted' then
chat_member_status = {
is_member = right[1] or 1,
restricted_until_date = right[2] or 0,
can_send_messages = right[3] or 1,
can_send_media_messages = right[4] or 1,
can_send_other_messages = right[5] or 1,
can_add_web_page_previews = right[6] or 1
}
chat_member_status._ = 'chatMemberStatus' .. Restricted
assert (tdbot_function ({_ = 'changeChatMemberStatus',chat_id = chat_id,user_id = user_id,status = chat_member_status}, dl_cb, nil))
end
end

function is_channel(msg)
chat_id = tostring(msg.chat_id)
if chat_id:match('^-100') then
if msg.is_post then
return true
else
return false
end
end
end


function AntiFloodReacTance(msg,type)
if type == 'ban' then
if is_banned(msg.chat_id, msg.sender_user_id) then
else
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..msg.sender_user_id..'</code> - @'..result.username..''
else
username = '<code>'..msg.sender_user_id..'</code>'
end
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به دلیل ارسال بیش از حد مجاز پیام اخراج شد !', 'html')
KickUser(msg.chat_id, msg.sender_user_id)
end
getUser(msg.sender_user_id, name, nil)
end
end
end

function Setadmin(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('admins',user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست ادمین ها وجود دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به لیست ادمین ها اضافه شد !', 'html')
redis:sadd('admins',user)
end
end
getUser(user, name, nil)
end

function Remadmin(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('admins',user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست ادمین ها وجود ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از لیست ادمین ها حذف شد !', 'html')
redis:srem('admins',user)
end
end
getUser(user, name, nil)
end

function Banall(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if tonumber(user) == tonumber(Mehdi) then
else
if redis:sismember('gbaned',user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مسدودین کلی وجود دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به لیست مسدودین کلی اضافه شد !', 'html')
redis:sadd('gbaned',user)
local bgps = redis:smembers('donegp') or 0
for i=1, #bgps do
KickUser(bgps[i], user)
end
end
end
end
getUser(user, name, nil)
end

function Unbanall(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('gbaned',user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مسدودین کلی وجود ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از لیست مسدودین کلی حذف شد !', 'html')
redis:srem('gbaned',user)
local bgps = redis:smembers('donegp') or 0
for i=1, #bgps do
RemoveFromBanList(bgps[i], user)
end
end
end
getUser(user, name, nil)
end

function SetOwner(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('owners'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مالکین گروه وجود دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به لیست مالکین گروه اضافه شد !', 'html')
redis:sadd('owners'..chat,user)
end
end
getUser(user, name, nil)
end

function RemOwner(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('owners'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مالکین گروه وجود ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از لیست مالکین گروه حذف شد !', 'html')
redis:srem('owners'..chat,user)
end
end
getUser(user, name, nil)
end

function AddAdmin(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» با موفقیت به مدیریت گروه ترفیع یافت !', 'html')
setgpadmin(chat, user, 'Administrator', {0, 1, 0, 0, 1, 1, 1, 1, 0})
end
getUser(user, name, nil)
end

function DelAdmin(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» با موفقیت از مدیریت گروه عزل شد !', 'html')
setgpadmin(chat, user, 'Administrator', {0, 0, 0, 0, 0, 0, 0, 0, 0})
end
getUser(user, name, nil)
end

function Promote(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('mods'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مدیران گروه وجود دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به لیست مدیران گروه اضافه شد !', 'html')
redis:sadd('mods'..chat,user)
end
end
getUser(user, name, nil)
end

function Demote(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('mods'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست مدیران گروه وجود ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از لیست مدیران گروه حذف شد !', 'html')
redis:srem('mods'..chat,user)
end
end
getUser(user, name, nil)
end

function Vip(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('vips'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست کاربران ویژه وجود دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به لیست کاربران ویژه اضافه شد !', 'html')
redis:sadd('vips'..chat,user)
end
end
getUser(user, name, nil)
end

function RemVip(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('vips'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در لیست کاربران ویژه وجود ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از لیست کاربران ویژه حذف شد !', 'html')
redis:srem('vips'..chat,user)
end
end
getUser(user, name, nil)
end

function Warn(msg,chat,user)
local function name(extra, result, success)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if priv(chat,user) then
sendText(msg.chat_id, msg.id, '• شما دسترسی لازم برای اخطار دادن به [ مدیران | سازندگان ] ربات را ندارید !', 'html')
else
nwarn = tonumber(redis:hget("warn"..chat, user) or 0)
wmax = tonumber(redis:hget("warn"..chat, "warnmax") or 3)
if nwarn + 1 == wmax then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» به دلیل دریافت بیش از حد مجاز اخطار اخراج میشوید !', 'html')
KickUser(chat, user)
redis:hset("warn"..chat, user, 0)
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» شما [ '..(nwarn + 1)..'/'..wmax..' ] اخطار دریافت کردید !', 'html')
redis:hset("warn"..chat, user, nwarn + 1)
end
end
end
getUser(user, name, nil)
end

function Remwarn(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:hget("warn"..chat, user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در حال حاضر اخطاری دریافت نکرده است !', 'html')
warnhash = redis:hget("warn"..chat, user)
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» اخطارهای شما با موفقیت پاکسازی شدند !', 'html')
redis:hdel("warn"..chat, user, 0)
end
end
getUser(user, name, nil)
end

function kicck(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
if priv(chat,user) then
else
KickUser(chat, user)
end
end

function kick(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
if priv(chat,user) then
sendText(msg.chat_id, msg.id, '• شما دسترسی لازم برای اخراج کردن [ مدیران | سازندگان ] ربات را ندارید !', 'html')
else
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از گروه اخراج شد !', 'html')
KickUser(chat, user)
end
getUser(user, name, nil)
end
end

function ban(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
if priv(chat,user) then
sendText(msg.chat_id, msg.id, '• شما دسترسی لازم برای مسدود کردن [ مدیران | سازندگان ] ربات را ندارید !', 'html')
else
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('banned'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از گروه مسدود شده است !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از گروه مسدود شد !', 'html')
KickUser(chat, user)
redis:sadd('banned'..chat,user)
end
end
getUser(user, name, nil)
end
end

function unban(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('banned'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از گروه مسدود نشده است !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از گروه لغو مسدودیت شد !', 'html')
RemoveFromBanList(chat, user)
redis:srem('banned'..chat,user)
end
end
getUser(user, name, nil)
end

function mute(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
if priv(chat,user) then
sendText(msg.chat_id, msg.id, '• شما دسترسی لازم برای ساکت کردن [ مدیران | سازندگان ] ربات را ندارید !', 'html')
else
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if redis:sismember('mutes'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در حالت سکوت قرار دارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در حالت سکوت قرار گرفت !', 'html')
redis:sadd('mutes'..chat,user)
end
end
getUser(user, name, nil)
end
end

function unmute(msg,chat,user)
if tonumber(user) == tonumber(ReacTance_id) then
return false
end
local function name(extra, result, success)
if result.username ~= '' then
username = '<code>'..user..'</code> - @'..result.username..''
else
username = '<code>'..user..'</code>'
end
if not redis:sismember('mutes'..chat,user) then
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» در حالت سکوت قرار ندارد !', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] \n\n» از حالت سکوت خارج شد !', 'html')
redis:srem('mutes'..chat,user)
end
end
getUser(user, name, nil)
end


function DarkLiNuX(msg,data)

if msg.date < tonumber(os.time() - 15) then
print("\027["..color.blue[1].."m------\027[00m \027["..color.red[1].."mU P D A T I N G\027[00m \027["..color.blue[1].."m------\027[00m")
return false
end

if msg.chat_id then
local id = tostring(msg.chat_id)
if id:match('-100(%d+)') then
grouptype = "supergroup"
if not redis:sismember("sgps",msg.chat_id) then
redis:sadd("sgps",msg.chat_id)
end
elseif id:match('^-(%d+)') then
grouptype = "group"
if not redis:sismember("gps",msg.chat_id) then
redis:sadd("gps",msg.chat_id)
end
elseif id:match('^(%d+)') then
grouptype = "pv"
if not redis:sismember("users",msg.chat_id) then
redis:sadd("users",msg.chat_id)
end
end
end
redis:incr("allmsg")
redis:incr('groupmsgs'..msg.chat_id..':')
redis:incr('usermsgs'..msg.chat_id..':'..msg.sender_user_id)

if tonumber(msg.sender_user_id) == tonumber(ReacTance_id) then
return false
end

if grouptype == "supergroup" or grouptype == "group" then
if not redis:get("gpname"..msg.chat_id) then
function GpName(extra, result, success)
if result.title then
text = result.title
redis:set("groupName"..msg.chat_id, text)
end
end
getChat(msg.chat_id, GpName, nil)
redis:setex("gpname"..msg.chat_id, 86400, true)
end
end

if grouptype == "supergroup" and not is_channel(msg) then
if not redis:get("gpmemb"..msg.chat_id) then
local function groupinfo(extra, result, success)
if result.member_count then
text = result.member_count
redis:set("groupmembers"..msg.chat_id, text)
end
end
getChannelFull(msg.chat_id, groupinfo, nil)
redis:setex("gpmemb"..msg.chat_id, 86400, true)
end
end

if not is_channel(msg) then
if grouptype == "supergroup" or grouptype == "group" then
if not redis:get("timesetusern"..msg.sender_user_id) then
function name(extra, result, success)
if result.username ~= '' then
text = result.username
redis:set("usrname"..msg.sender_user_id, text)
end
end
getUser(msg.sender_user_id, name, nil)
redis:setex("timesetusern"..msg.sender_user_id, 86400, true)
end
end
end

local text = msg.content.text
if text and text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
text = text
end

if msg.content._ == 'messageText' and text then
if text:match('^[#/!]') then
text = text:gsub('^[#/!]','')
end
end

if not is_channel(msg) then
if grouptype == "supergroup" then
if msg.content._ == "messageChatAddMembers" then
redis:incr(msg.chat_id..'addmembers'..msg.sender_user_id)
end
end
end

if not is_channel(msg) then
if msg.content._ == "messageChatAddMembers" then
if tonumber(msg.content.member_user_ids[0]) == tonumber(ReacTance_id) then
local function GpName(extra, result, success)
local name = okname(result.title)
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '<code>'..msg.sender_user_id..'</code> - @'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(Logs, msg.id, '• ربات به گروهی اضافه شد !\n\n» توسط : [ '..username..' ]\n\n» شناسه گروه : [ <code>'..msg.chat_id..'</code> ]\n\n» نام گروه : [ '..name..' ]', 'html')
end
getChat(msg.chat_id, GpName, nil)
end
end
if grouptype == "supergroup" then
if msg.content._ == "messageChatAddMembers" then
if tonumber(msg.content.member_user_ids[0]) == tonumber(ReacTance_id) then
sendText(msg.chat_id, msg.id, "• ربات با موفقیت به گروه شما اضافه شد !\n\n» لطفا برای نصب ربات در گروه از دستور\n/start\nاستفاده کنید .\n\n» در صورت نیاز به پشتیبانی به گروه پشتیبانی ربات مراجعه کنید .\n\n[» Click To Join Support Group «]("..support..")\n\n• Ch : "..channel.." ", 'md')
end
end
end
end

if not is_channel(msg) then
if grouptype == "supergroup" then
floods = redis:hget("flooding:settings:"..msg.chat_id,"flood") or  'nil'
NUM_MSG_MAX = redis:hget("flooding:settings:"..msg.chat_id,"floodmax") or 5
TIME_CHECK = redis:hget("flooding:settings:"..msg.chat_id,"floodtime") or 3
if redis:hget("flooding:settings:"..msg.chat_id,"flood") then
if not is_vip(msg) then
if msg.content._ == "messageChatAddMembers" then
return
elseif msg.edit_date > 0 then
return
else
local post_count = tonumber(redis:get('floodc:'..msg.sender_user_id..':'..msg.chat_id) or 0)
if post_count > tonumber(redis:hget("flooding:settings:"..msg.chat_id,"floodmax") or 5) then
local type = redis:hget("flooding:settings:"..msg.chat_id,"flood")
AntiFloodReacTance(msg,type)
end
redis:setex('floodc:'..msg.sender_user_id..':'..msg.chat_id, tonumber(redis:hget("flooding:settings:"..msg.chat_id,"floodtime") or 3), post_count+1)
end
end
end
end
end

if redis:get("atolct2"..msg.chat_id) or redis:get("atolct2"..msg.chat_id) then
local time = os.date("%H%M")
local time2 = redis:get("atolct1"..msg.chat_id)
time2 = time2.gsub(time2,":","")
local time3 = redis:get("atolct2"..msg.chat_id)
time3 = time3.gsub(time3,":","")
if tonumber(time3) < tonumber(time2) then
if tonumber(time) <= 2359 and tonumber(time) >= tonumber(time2) then
if not redis:get("lc_ato:"..msg.chat_id) then
redis:set("lc_ato:"..msg.chat_id, true)
sendText(msg.chat_id, msg.id, '• زمان فعال شدن قفل خودکار رسیده است قفل خودکار فعال میشود !\n\n» ارسال پیام در گروه تا ساعت [ <code>'..redis:get("atolct2"..msg.chat_id)..'</code> ] ممنوع میباشد .\n\n• Ch : '..channel..'', 'html')
end
elseif tonumber(time) >= 0000 and tonumber(time) < tonumber(time3) then
if not redis:get("lc_ato:"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• زمان فعال شدن قفل خودکار رسیده است قفل خودکار فعال میشود !\n\n» ارسال پیام در گروه تا ساعت [ <code>'..redis:get("atolct2"..msg.chat_id)..'</code> ] ممنوع میباشد .\n\n• Ch : '..channel..'', 'html')
redis:set("lc_ato:"..msg.chat_id, true)
end
else
if redis:get("lc_ato:"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• زمان قفل خودکار به پایان رسیده است !\n\n» کاربران میتوانند مطالب خود را ارسال کنند .\n\n• Ch : '..channel..'', 'html')
redis:del("lc_ato:"..msg.chat_id, true)
end
end
elseif tonumber(time3) > tonumber(time2) then
if tonumber(time) >= tonumber(time2) and tonumber(time) < tonumber(time3) then
if not redis:get("lc_ato:"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• زمان فعال شدن قفل خودکار رسیده است قفل خودکار فعال میشود !\n\n» ارسال پیام در گروه تا ساعت [ <code>'..redis:get("atolct2"..msg.chat_id)..'</code> ] ممنوع میباشد .\n\n• Ch : '..channel..'', 'html')
redis:set("lc_ato:"..msg.chat_id, true)
end
else
if redis:get("lc_ato:"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• زمان قفل خودکار به پایان رسیده است !\n\n» کاربران میتوانند مطالب خود را ارسال کنند .\n\n• Ch : '..channel..'', 'html')
redis:del("lc_ato:"..msg.chat_id, true)
end
end
end
end

if text and not is_vip(msg) then
if is_filter(msg, text) then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption and not is_vip(msg) then
if is_filter(msg, msg.content.caption) then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('tgservice'..msg.chat_id) then
if msg.content._ == "messageChatJoinByLink" or msg.content._ == "messageChatAddMembers" or msg.content._ == "messageChatDeleteMember" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if msg.sender_user_id and is_gban(msg.chat_id, msg.sender_user_id) then
KickUser(msg.chat_id, msg.sender_user_id)
deleteMessages(msg.chat_id, {[0] = msg.id})
return false
end
if msg.content._ == "messageChatAddMembers" then
if is_gban(msg.chat_id, msg.content.member_user_ids[0]) then
RemoveFromBanList(msg.chat_id, msg.content.member_user_ids[0])
end
end

local welcome = (redis:get('welcome'..msg.chat_id) or 'disable')
if welcome == 'enable' then
if msg.content._ == "messageChatJoinByLink" then
if is_banned(msg.chat_id, msg.sender_user_id) then
KickUser(msg.chat_id, msg.sender_user_id)
elseif tonumber(msg.sender_user_id) == tonumber(Mehdi) then
local data = {
"جوووووووون باباییم اومد ^_^",
"باباییم 😻",
"سعلامممممممممممممم بابایی ^.^\nاینا منو اذیت میکنن :(",
"خوش اومدی بابایی *.*",
"باباییمو :)))",
}
sendText(msg.chat_id, msg.id, data[math.random(#data)], 'html')
else
function welcomelink(extra, result, success)
local GroupName = redis:get('groupName'..msg.chat_id)
if redis:get('welcome:'..msg.chat_id) then
txtt = redis:get('welcome:'..msg.chat_id)
else
txtt = 'سلام ❤️\n\nبه گروه ( '..(GroupName or 'Not Set')..' ) خوش امدید 🌹\n\nساعت : [ '..os.date("%H:%M:%S")..' ]\n\n • Ch : '..channel..''
end
local rules = redis:get("rules"..msg.chat_id)
local link = redis:get("link"..msg.chat_id)
local txtt = txtt:gsub('{firstname}',okname(result.first_name))
local txtt = txtt:gsub('{grouprules}',rules or '')
local txtt = txtt:gsub('{grouplink}',link or '')
local txtt = txtt:gsub('{lastname}',result.last_name or '')
local txtt = txtt:gsub('{userid}',msg.sender_user_id or '')
local txtt = txtt:gsub('{username}','@'..result.username or '')
local txtt = txtt:gsub('{groupname}',GroupName or '')
local txtt = txtt:gsub('{time}',os.date("%H:%M:%S"))
sendText(msg.chat_id, msg.id, txtt, 'html')
end
getUser(msg.sender_user_id, welcomelink)
end
end
end

if not is_vip(msg) then

if redis:get('link'..msg.chat_id) then
if msg.content.text then
local link = (msg.content.text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.content.text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or msg.content.text:match("[Tt].[Mm][Ee]/") or msg.content.text:match('(.*)[.][mM][Ee]') or msg.content.text:match('[Ww][Ww][Ww].(.*)') or msg.content.text:match('(.*).[Ii][Rr]') or msg.content.text:match('[Hh][Tt][Tt][Pp][Ss]://(.*)') or msg.content.text:match('[Ww][Ww][Ww].(.*)') or msg.content.text:match('http://(.*)'))
if link  then
if msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeUrl" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end
if msg.content.caption then
local link = (msg.content.caption:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or msg.content.caption:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or msg.content.caption:match("[Tt].[Mm][Ee]/") or msg.content.caption:match('(.*)[.][mM][Ee]') or msg.content.caption:match('(.*).[Ii][Rr]') or msg.content.caption:match('[Ww][Ww][Ww].(.*)') or msg.content.caption:match('[Hh][Tt][Tt][Pp][Ss]://') or msg.content.caption:match('http://(.*)'))
if link then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

if redis:get('username'..msg.chat_id) then
if msg.content.text then
local tag = msg.content.text:match("@(.*)") or msg.content.text:match("@")
if tag then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption then
local tag = msg.content.caption:match("@(.*)")
if tag then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

if redis:get('hashtag'..msg.chat_id) then
if msg.content.text then
if msg.content.text:match("#(.*)") or msg.content.text:match("#(.*)") or msg.content.text:match("#") then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption then
if msg.content.caption:match("#(.*)")  or msg.content.caption:match("(.*)#") or msg.content.caption:match("#") then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

if redis:get('sticker'..msg.chat_id) then
if msg.content._ == "messageSticker" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('join'..msg.chat_id) then
if msg.content._ == "messageChatJoinByLink" then
KickUser(msg.chat_id, msg.sender_user_id)
end
end

if redis:get('forward'..msg.chat_id) then
if msg.forward_info then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('photo'..msg.chat_id) then
if msg.content._ == "messagePhoto" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('document'..msg.chat_id) then
if msg.content._ == "messageDocument" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('game'..msg.chat_id) then
if msg.content.game then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('music'..msg.chat_id) then
if msg.content._ == "messageAudio" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('voice'..msg.chat_id) then
if msg.content._ == "messageVoice" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('gif'..msg.chat_id) then
if msg.content._ == "messageAnimation" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('contact'..msg.chat_id) then
if msg.content._ == "messageContact" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('video'..msg.chat_id) then
if msg.content._ == "messageVideo" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('location'..msg.chat_id) then
if msg.content._ == "messageLocation" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('inline'..msg.chat_id) then
if msg.reply_markup and msg.reply_markup._ == "replyMarkupInlineKeyboard" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('videonote'..msg.chat_id) then
if msg.content._ == "messageVideoNote" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('text'..msg.chat_id) then
if msg.content._== "messageText" then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end

if redis:get('persian'..msg.chat_id) then
if msg.content.text then
if msg.content.text:match('[\216-\219][\128-\191]') then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption then
local is_persian = msg.content.caption:match("[\216-\219][\128-\191]")
if is_persian then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

if redis:get('english'..msg.chat_id) then
if msg.content.text then
if (msg.content.text:match("[A-Z]") or msg.content.text:match("[a-z]")) then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption then
local is_english = (msg.content.caption:match("[A-Z]") or msg.content.caption:match("[a-z]"))
if is_english then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

if redis:get('badword'..msg.chat_id) then
if msg.content.text then
if (msg.content.text:match("کیر") or msg.content.text:match("تخم") or msg.content.text:match("جینده") or msg.content.text:match("کص") or msg.content.text:match("کونی") or msg.content.text:match("جندع") or msg.content.text:match("کیری") or msg.content.text:match("کصده") or msg.content.text:match("کون") or msg.content.text:match("جنده") or msg.content.text:match("ننه") or msg.content.text:match("ننت") or  msg.content.text:match("کیرم") or msg.content.text:match("تخمم") or msg.content.text:match("تخم") or msg.content.text:match("ننع") or msg.content.text:match("مادر") or msg.content.text:match("قهبه") or msg.content.text:match("گاییدی") or msg.content.text:match("گاییدم") or msg.content.text:match("میگام") or msg.content.text:match("میگامت") or msg.content.text:match("سکس") or msg.content.text:match("kir") or msg.content.text:match("kos") or msg.content.text:match("kon") or msg.content.text:match("nne") or msg.content.text:match("nnt") or msg.content.text:match("kiri") or msg.content.text:match("ks nnt") or msg.content.text:match("jnde") or msg.content.text:match("jende") or msg.content.text:match("koni")) then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
if msg.content.caption then
local is_badword = (msg.content.caption:match("کیر") or msg.content.caption:match("تخم") or msg.content.caption:match("جینده") or msg.content.caption:match("کص") or msg.content.caption:match("کونی") or msg.content.caption:match("جندع") or msg.content.caption:match("کیری") or msg.content.caption:match("کصده") or msg.content.caption:match("کون") or msg.content.caption:match("جنده") or msg.content.caption:match("ننه") or msg.content.caption:match("ننت") or msg.content.caption:match("کیرم") or msg.content.caption:match("تخمم") or msg.content.caption:match("تخم") or msg.content.caption:match("ننع") or msg.content.caption:match("مادر") or msg.content.caption:match("قهبه") or msg.content.caption:match("گاییدی") or msg.content.caption:match("گاییدم") or msg.content.caption:match("میگام") or msg.content.caption:match("میگامت") or msg.content.caption:match("سکس") or msg.content.caption:match("kir") or msg.content.caption:match("kos") or msg.content.caption:match("kon") or msg.content.caption:match("nne") or msg.content.caption:match("nnt") or msg.content.caption:match("kiri") or msg.content.caption:match("ks nnt") or msg.content.caption:match("jnde") or msg.content.caption:match("jende") or msg.content.caption:match("koni"))
if is_badword then
deleteMessages(msg.chat_id, {[0] = msg.id})
end
end
end

local muteall = redis:get('muteall'..msg.chat_id)
if msg.sender_user_id and muteall then
deleteMessages(msg.chat_id, {[0] = msg.id})
return false
end

if msg.sender_user_id and is_muted(msg.chat_id, msg.sender_user_id) then
deleteMessages(msg.chat_id, {[0] = msg.id})
return false
end

if msg.sender_user_id and is_banned(msg.chat_id, msg.sender_user_id) then
KickUser(msg.chat_id, msg.sender_user_id)
deleteMessages(msg.chat_id, {[0] = msg.id})
return false
end

if redis:get("lc_ato:"..msg.chat_id) then
deleteMessages(msg.chat_id, {[0] = msg.id})
return false
end

if redis:get('cmd'..msg.chat_id) then
if not is_vip(msg) then
return false
end
end

end -- not vip


if text then

if (text:match("^[Ss][Tt][Aa][Rr][Tt]$") or text:match("^setup"..botusername.."$")) and grouptype == "group" and tonumber(msg.reply_to_message_id) == 0 then
sendText(msg.chat_id, msg.id, '• ربات توانایی نصب شدن در گروه معمولی را ندارد !\n\n» در صورت نیاز به پشتیبانی به گروه پشتیبانی ربات مراجعه کنید .\n\n[» Click To Join Support Group «]('..support..')\n\n• Ch : '..channel..'', 'md')
end
if (text:match("^[Ss][Tt][Aa][Rr][Tt]$") or text:match("^start"..botusername.."$")) and grouptype == "supergroup" and not is_channel(msg) and tonumber(msg.reply_to_message_id) == 0 then
local function GetCreator(extra, result, success)
if redis:sismember("donegp", msg.chat_id) then
sendText(msg.chat_id, msg.id, '• این گروه از قبل نصب شده است !\n\n» در صورت نیاز به پشتیبانی به گروه پشتیبانی ربات مراجعه کنید .\n\n[» Click To Join Support Group «]('..support..')\n\n• Ch : '..channel..'', 'md')
else
for k,v in pairs(result.members) do
if v.status._ == "chatMemberStatusCreator" then
local addmins = tonumber(result.total_count) -1
local function name(arg, data, success)
if data.username ~= '' then
username = '<code>'..v.user_id..'</code> - @'..data.username..''
else
username = '<code>'..v.user_id..'</code> - <a href="tg://user?id='..v.user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• ربات با موفقیت در گروه نصب شد !\n\n» کاربر [ '..username..' ] به عنوان مالک گروه تنظیم شد !\n\n» [ '..addmins..' ] ادمین شناسایی شده با موفقیت ترفیع یافتند .\n\n» برای اطلاع از دستورات ربات میتوانید از دستور زیر استفاده کنید 👇🏻\n/panel\n\n» درصورت وجود هرگونه مشکل در نصب یا ربات با آیدی های زیر یا گروه پشتیبانی در ارتباط باشید :\n- { '..Usersudo..' }\n- { '..support..' }\n\n• Ch : '..channel..'', 'html')
redis:sadd("donegp", msg.chat_id)
redis:set('checkdone'..msg.chat_id, true)
redis:incr('addlistbot'..msg.sender_user_id..':')
redis:set('link'..msg.chat_id, true)
redis:set('forward'..msg.chat_id, true)
redis:set('bot'..msg.chat_id, true)
end
redis:sadd('owners'..msg.chat_id, v.user_id)
getUser(v.user_id, name, nil)
end
end
for p,t in pairs(result.members) do
if t.status._== "chatMemberStatusAdministrator" then
redis:sadd('mods'..msg.chat_id, t.user_id)
end
end
local GroupName = redis:get('groupName'..msg.chat_id)
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '<code>'..msg.sender_user_id..'</code> - @'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(Logs, msg.id, '• ربات در گروهی نصب شد !\n\n» توسط : [ '..username..' ]\n\n» شناسه گروه : [ '..msg.chat_id..' ]\n\n» نام گروه : [ '..(GroupName or 'Not Set')..' ]', 'html')
forward(Logs, msg.chat_id, {[0] = msg.id}, 0)
end
end
getChannelMembers(msg.chat_id, 'Administrators' ,0, 200, GetCreator)
end


if is_sudo(msg) then
if text:match("^[Cc][Mm]$") then 
    function CleanMembers(extra, result, success) 
    for k, v in pairs(result.members) do 
 if tonumber(v.user_id) == tonumber(ReacTance_id)  then
    return true
    end
KickUser(msg.chat_id,v.user_id)
end
end
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
getChannelMembers(msg.chat_id,"Recent",0, 2000000,CleanMembers)
sendText(msg.chat_id, msg.id, '• عملیات با موفقیت انجام شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
end

if text:match("^[Cc][Mm][Ff][Ll]$") and tonumber(msg.reply_to_message_id) == 0 then
local bgps = redis:smembers('donegp') or 0
for i=1, #bgps do
redis:del('filters'..bgps[i])
end
sendText(msg.chat_id, msg.id, 'Done', 'html')
end

if text:match("^[Ff] (.*)$") and tonumber(msg.reply_to_message_id) > 0 then
local action = text:match("^[Ff] (.*)$")
if action == "sgps" then
local gp = redis:smembers("sgps") or 0
local gps = redis:scard("sgps") or 0
for i=1, #gp do
forward(gp[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] سوپرگروه فوروارد شد !', 'html')
elseif action == "g" then
local gp = redis:smembers("gps") or 0
local gps = redis:scard("gps") or 0
for i=1, #gp do
forward(gp[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] گروه فوروارد شد !', 'html')
elseif action == "p" then
local gp = redis:smembers("users") or 0
local gps = redis:scard("users") or 0
for i=1, #gp do
forward(gp[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] کاربر فوروارد شد !', 'html')
elseif action == "a" then
local pv = redis:smembers("users") or 0
local pvv = redis:scard("users") or 0
for i=1, #pv do
forward(pv[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
local gp = redis:smembers("gps") or 0
local gps = redis:scard("gps") or 0
for i=1, #gp do
forward(gp[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
local sgp = redis:smembers("sgps") or 0
local sgps = redis:scard("sgps") or 0
for i=1, #sgp do
forward(sgp[i], msg.chat_id, {[0] = msg.reply_to_message_id}, 1)
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..sgps..' ] سوپر گروه [ '..gps..' ] گروه و [ '..pvv..' ] کاربر فوروارد شد !', 'html')
end
end

if text:match("^[Bb] (.*)$") and tonumber(msg.reply_to_message_id) > 0 then
local action = text:match("^[Bb] (.*)$")
function getmsg(extra, result, success)
if action == "s" then
local txt = result.content.text
local gp = redis:smembers("sgps") or 0
local gps = redis:scard("sgps") or 0
for i=1, #gp do
sendText(gp[i], 0, txt, 'md')
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] سوپرگروه ارسال شد !', 'html')
elseif action == "g" then
local txt = result.content.text
local gp = redis:smembers("gps") or 0
local gps = redis:scard("gps") or 0
for i=1, #gp do
sendText(gp[i], 0, txt, 'md')
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] گروه ارسال شد !', 'html')
elseif action == "p" then
local txt = result.content.text
local gp = redis:smembers("users") or 0
local gps = redis:scard("users") or 0
for i=1, #gp do
sendText(gp[i], 0, txt, 'md')
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..gps..' ] کاربر ارسال شد !', 'html')
elseif action == "a" then
local txt = result.content.text
local pv = redis:smembers("users") or 0
local pvv = redis:scard("users") or 0
for i=1, #pv do
sendText(pv[i], 0, txt, 'md')
end
local txt = result.content.text
local gp = redis:smembers("gps") or 0
local gps = redis:scard("gps") or 0
for i=1, #gp do
sendText(gp[i], 0, txt, 'md')
end
local txt = result.content.text
local sgp = redis:smembers("sgps") or 0
local sgps = redis:scard("sgps") or 0
for i=1, #sgp do
sendText(sgp[i], 0, txt, 'md')
end
sendText(msg.chat_id, msg.id, '• پیام شما با موفقیت به [ '..sgps..' ] سوپر گروه [ '..gps..' ] گروه و [ '..pvv..' ] کاربر ارسال شد !', 'html')
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), getmsg)
end

if text:match("^[Ll][Uu][Aa] (.*)") and tonumber(msg.reply_to_message_id) == 0 then
local mehdi = text:match("^[Ll][Uu][Aa] (.*)")
local output = loadstring(mehdi)()
if output == nil then
output = ""
elseif type(output) == "table" then
output = serpent.block(output, {comment = false})
else
utput = "" .. tostring(output)
end
sendText(msg.chat_id, msg.id, '<code>'..output..'</code>', 'html')
end

if text:match("^[Ff]orcejoin [Oo]n$") and tonumber(msg.reply_to_message_id) == 0 then
if not redis:get("force") then
sendText(msg.chat_id, msg.id, '<i>• جوین اجباری با موفقیت فعال شد !</i>' ,'html')
redis:set("force", true)
else
sendText(msg.chat_id, msg.id, '<i>• جوین اجباری از قبل فعال بود !</i>' ,'html')
end
elseif text:match("^[Ff]orcejoin [Oo]ff$") and tonumber(msg.reply_to_message_id) == 0 then
if redis:get("force") then
sendText(msg.chat_id, msg.id, '<i>• جوین اجباری با موفقیت غیرفعال شد !</i>' ,'html')
redis:del("force", true)
else
sendText(msg.chat_id, msg.id, '<i>• جوین اجباری از قبل غیرفعال بود !</i>' ,'html')
end
end

if text:match('^[Ff][Uu][Cc][Kk][Uu][Pp]$') and tonumber(msg.reply_to_message_id) == 0 then
local url , res = http.request('http://probot.000webhostapp.com/api/time.php/')
if res ~= 200 then return sendText(msg.chat_id, msg.id, '> Error 404 :|', 'html') end
local jdat = json:decode(url)
local total = io.popen("du -h ./bot.lua"):read("*a")
local size = total:match("%d+K")
sendText(msg.chat_id, msg.id, '• <i>نسخه کنونی ربات برای سازنده ارسال شد !</i>' ,'html')
sendDocument(Mehdi, msg.id, './bot.lua','• نسخه کنونی ربات دلتا !\n» زمان : [ '..jdat.Stime..' ]\n» تاریخ : [ '..jdat.FAdate..' ]\n» حجم سورس : [ '..size..' ]\n• Ch : '..channel..'')
end

if text:match('^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]$') and tonumber(msg.reply_to_message_id) > 0 then
function SetMod(extra, result, success)
Setadmin(msg, msg.chat_id, result.sender_user_id)
end
getMessage(msg.chat_id, msg.reply_to_message_id, SetMod)
end

if text:match('^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 then
id = msg.content.entities[0].type.user_id
Setadmin(msg, msg.chat_id, id)
end

if text:match('^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 then
local username = text:match('[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$')
function modusername(extra,result,success)
if result.id then
Setadmin(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, modusername)
end

if text:match('^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 then
Setadmin(msg, msg.chat_id, text:match('^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$'))
end

if text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]$') and tonumber(msg.reply_to_message_id) > 0 then
function RemMod(extra, result, success)
Remadmin(msg, msg.chat_id, result.sender_user_id)
end
getMessage(msg.chat_id, msg.reply_to_message_id, RemMod)
end

if text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 then
id = msg.content.entities[0].type.user_id
Remadmin(msg, msg.chat_id, id)
end

if text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 then
local username = text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$')
function remmodusername(extra,result,success)
if result.id then
Remadmin(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, remmodusername)
end

if text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 then
Remadmin(msg, msg.chat_id, text:match('^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$'))
end

if text:match('^[Aa][Dd][Mm][Ii][Nn][Ss]$') and tonumber(msg.reply_to_message_id) == 0 then
local list = redis:smembers('admins')
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مدیران ربات خالی میباشد !', 'md')
else
local txt = '» لیست مدیران ربات :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Aa][Dd][Mm][Ii][Nn][Ss]$') and tonumber(msg.reply_to_message_id) == 0 then
list = redis:smembers('admins')
num = redis:scard('admins')
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مدیران ربات خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست مدیران ربات پاکسازی شد !\n\n» تعداد مدیران : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('admins')
end
end

if text:match('^[Bb][Aa][Nn][Aa][Ll][Ll]$') and tonumber(msg.reply_to_message_id) > 0 then
function SetMod(extra, result, success)
Banall(msg, msg.chat_id, result.sender_user_id)
end
getMessage(msg.chat_id, msg.reply_to_message_id, SetMod)
end

if text:match('^[Bb][Aa][Nn][Aa][Ll][Ll] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 then
id = msg.content.entities[0].type.user_id
Banall(msg, msg.chat_id, id)
end

if text:match('^[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 then
local username = text:match('[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$')
function modusername(extra,result,success)
if result.id then
Banall(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, modusername)
end

if text:match('^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 then
Banall(msg, msg.chat_id, text:match('^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$'))
end

if text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$') and tonumber(msg.reply_to_message_id) > 0 then
function RemMod(extra, result, success)
Unbanall(msg, msg.chat_id, result.sender_user_id)
end
getMessage(msg.chat_id, msg.reply_to_message_id, RemMod)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 then
id = msg.content.entities[0].type.user_id
Unbanall(msg, msg.chat_id, id)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 then
local username = text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$')
function remmodusername(extra,result,success)
if result.id then
Unbanall(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, remmodusername)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 then
Unbanall(msg, msg.chat_id, text:match('^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$'))
end

if text:match('^[Bb][Aa][Nn][Aa][Ll][Ll][Ss]$') and tonumber(msg.reply_to_message_id) == 0 then
local list = redis:smembers('gbaned')
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مسدودین کلی خالی میباشد !', 'md')
else
local txt = '» لیست مسدودین کلی :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Bb][Aa][Nn][Aa][Ll][Ll][Ss]$') and tonumber(msg.reply_to_message_id) == 0 then
list = redis:smembers('gbaned')
num = redis:scard('gbaned')
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مسدودین کلی خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست مسدودین کلی پاکسازی شد !\n\n» تعداد مسدودین : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('gbaned')
end
end

end -- end sudo


if is_admin(msg) then

if text:match("^[Aa][Dd][Dd]$") and tonumber(msg.reply_to_message_id) == 0 then
if redis:sismember("donegp", msg.chat_id) then
local GroupName = redis:get('groupName'..msg.chat_id)
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '<code>'..msg.sender_user_id..'</code> - @'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• این گروه از قبل نصب شده است !\n\n» در صورت نیاز به پشتیبانی به گروه پشتیبانی ربات مراجعه کنید .\n\n» لینک : \n• { '..support..' } •\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• ربات با موفقیت در گروه نصب شد !\n\n» برای اطلاع از دستورات ربات میتوانید از دستور زیر استفاده کنید 👇🏻\n/panel\n\n» درصورت وجود هرگونه مشکل در نصب یا ربات با آیدی های زیر یا گروه پشتیبانی در ارتباط باشید :\n- { '..Usersudo..' }\n- { '..support..' }\n\n• Ch : '..channel..'', 'html')
redis:sadd("donegp", msg.chat_id)
redis:set('checkdone'..msg.chat_id, true)
redis:incr('addlistbot'..msg.sender_user_id..':')
sendText(Logs, msg.id, '• ربات در گروهی نصب شد !\n\n» توسط : [ '..username..' ]\n\n» شناسه گروه : [ '..msg.chat_id..' ]\n\n» نام گروه : [ '..(GroupName or 'Not Set')..' ]', 'html')
forward(Logs, msg.chat_id, {[0] = msg.id}, 0)
end
end

if text:match('^[Ss][Ee][Tt][Rr][Aa][Nn][Kk] (.*)$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
local rank = text:match('^[Ss][Ee][Tt][Rr][Aa][Nn][Kk] (.*)$')
local function Setrank(extra, result, success)
local function name(arg, data, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
elseif tonumber(result.sender_user_id) == tonumber(ReacTance_id) then
sendText(msg.chat_id, msg.reply_to_message_id, 'به کیرم دست نزن :(', 'md')
elseif tonumber(result.sender_user_id) == tonumber(Mehdi) then
sendText(msg.chat_id, msg.reply_to_message_id, 'بابایی به کیرم دست زد :(', 'md')
else
if data.username ~= '' then
username = '<code>'..result.sender_user_id..'</code> - @'..data.username..''
else
username = '<code>'..result.sender_user_id..'</code>'
end
sendText(msg.chat_id, msg.id, '• مقام کاربر [ '..username..' ] \n\n» به [ '..rank..' ] تنظیم شد !', 'html')
redis:set('ranks'..result.sender_user_id, rank)
end
end
getUser(result.sender_user_id, name, nil)
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Setrank)
end

if text:match('^[Rr][Ee][Ll][Oo][Aa][Dd]$') and tonumber(msg.reply_to_message_id) == 0 then
loadfile("./bot.lua")()
io.popen("rm -rf ~/.telegram-bot/main/files/animations/*")
io.popen("rm -rf ~/.telegram-bot/main/files/documents/*")
io.popen("rm -rf ~/.telegram-bot/main/files/music/*")
io.popen("rm -rf ~/.telegram-bot/main/files/photos/*")
io.popen("rm -rf ~/.telegram-bot/main/files/temp/*")
io.popen("rm -rf ~/.telegram-bot/main/files/video_notes/*")
io.popen("rm -rf ~/.telegram-bot/main/files/videos/*")
io.popen("rm -rf ~/.telegram-bot/main/files/voice/*")
io.popen("rm -rf ~/.telegram-bot/main/data/profile_photos/*")
io.popen("rm -rf ~/.telegram-bot/main/data/secret/*")
io.popen("rm -rf ~/.telegram-bot/main/data/secret_thumbnails/*")
io.popen("rm -rf ~/.telegram-bot/main/data/stickers/*")
io.popen("rm -rf ~/.telegram-bot/main/data/temp/*")
io.popen("rm -rf ~/.telegram-bot/main/data/thumbnails/*")
io.popen("rm -rf ~/.telegram-bot/main/data/wallpapers/*")
sendText(msg.chat_id, msg.id, '<i>• DELTA Robot Was Reloaded !</i>', 'html')
end

if text:match('^[Ll][Ee][Aa][Vv][Ee] (-100)(%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local chat_id = text:match('^[Ll][Ee][Aa][Vv][Ee] (.*)$')
local GroupName = redis:get('groupName'..chat_id)
local function name(arg, data, success)
if data.username ~= '' then
username = '<code>'..msg.sender_user_id..'</code> - @'..data.username..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
redis:del('mods'..chat_id)
redis:del('vips'..chat_id)
redis:del('warn'..chat_id)
redis:del('muteall'..chat_id)
redis:del('banned'..chat_id)
redis:del('mutes'..chat_id)
redis:del('filters'..chat_id)
redis:del('owners'..chat_id)
redis:del('rules'..chat_id)
redis:del('link'..chat_id)
redis:del('welcome:'..chat_id, welcome)
redis:del('checkdone'..chat_id)
redis:srem('donegp', chat_id)
sendText(msg.chat_id, msg.id,'» ربات با موفقیت از گروه { [ '..chat_id..' ] | [ '..(GroupName or 'Not Set')..' ] } خارج شد.','html')
sendText(Logs, msg.id, '» ربات از گروهی خارج شد !\n\n» توسط : [ '..username..' ]\n\n» شناسه گروه : [ '..chat_id..' ]\n\n» نام گروه : [ '..(GroupName or 'Not Set')..' ]','html')
forward(Logs, msg.chat_id, {[0] = msg.id}, 0)
Left(chat_id, ReacTance_id, "Left")
end
getUser(msg.sender_user_id, name, nil)
end

if text:match('^[Gg][Pp][Ii][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
sendText(msg.chat_id, msg.id, '• [ <code>'..msg.chat_id..'</code> ] •', 'html')
end

if text:match('^[Ll][Ee][Aa][Vv][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local GroupName = redis:get('groupName'..msg.chat_id)
redis:del('mods'..msg.chat_id)
redis:del('vips'..msg.chat_id)
redis:del('warn'..msg.chat_id)
redis:del('muteall'..msg.chat_id)
redis:del('banned'..msg.chat_id)
redis:del('mutes'..msg.chat_id)
redis:del('filters'..msg.chat_id)
redis:del('owners'..msg.chat_id)
redis:del('rules'..msg.chat_id)
redis:del('link'..msg.chat_id)
redis:del('welcome:'..msg.chat_id, welcome)
redis:del('checkdone'..msg.chat_id)
redis:srem('donegp', msg.chat_id)
sendText(msg.chat_id, msg.id, '• ربات از گروه خارج میشود !', 'html')
sendText(Logs, msg.id, '• ربات از گروهی خارج شد !\n\n» توسط : [ '..msg.sender_user_id..' ]\n\n» شناسه گروه : [ '..msg.chat_id..' ]\n\n» نام گروه : [ '..(GroupName or 'Not Set')..' ]', 'html')
forward(Logs, msg.chat_id, {[0] = msg.id}, 0)
Left(msg.chat_id, ReacTance_id, "Left")
end

if text:match('^[Gg][Rr][Oo][Uu][Pp][Ss]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
io.popen("rm -rf ReacTanceGroups.txt"):read("*all")
local num = tonumber(redis:scard('donegp'))
local list = redis:smembers('donegp')
local t = '» لیست گروهای مدیریتی ربات :\n\n'
for k,v in pairs(list) do
local GroupsOwner = redis:scard('owners'..v) or 0
local GroupsMod = redis:scard('mods'..v) or 0
local Groupslink = redis:get('link'..v)
local GroupsName = redis:get('groupName'..v)
local GroupsMember = redis:get('groupmembers'..v) or 0
local GroupsMsg = redis:get('groupmsgs'..v..':') or 0
t = t..k.." - ( "..(GroupsName or 'Not Found').." )\n» Group ID : [ "..v.." ]\n» Group Link : [ "..(Groupslink or 'Not Set').." ]\n» Group Owners : [ "..GroupsOwner.." ]\n» Group Mods : [ "..GroupsMod.." ]\n» Group Msgs : [ "..GroupsMsg.." ]\n» Group Members : [ "..GroupsMember.." ]\n---------------------------------------------------\n"
end
writefile("WizzlyGroups.txt", t)
sendDocument(msg.chat_id, msg.id, './WizzlyGroups.txt','• تعداد گروه ها : [ '..num..' ]\n\n• Ch : '..channel..'')
end

if text:match('^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function SetMod(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
SetOwner(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, SetMod)
end

if text:match('^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
SetOwner(msg, msg.chat_id, id)
end

if text:match('^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$')
function modusername(extra,result,success)
if result.id then
SetOwner(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, modusername)
end

if text:match('^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
SetOwner(msg, msg.chat_id, text:match('^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$'))
end

if text:match('^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]$') and tonumber(msg.reply_to_message_id) > 0 then
function RemMod(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
RemOwner(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, RemMod)
end

if text:match('^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
RemOwner(msg, msg.chat_id, id)
end

if text:match('^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$')
function remmodusername(extra,result,success)
if result.id then
RemOwner(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, remmodusername)
end

if text:match('^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
RemOwner(msg, msg.chat_id, text:match('^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$'))
end

if text:match('^[Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('owners'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مالکین گروه خالی میباشد !', 'md')
else
local txt = '» لیست مالکین گروه :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
list = redis:smembers('owners'..msg.chat_id)
num = redis:scard('owners'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مالکین گروه خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست مالکین گروه پاکسازی شد !\n\n» تعداد مالکین : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('owners'..msg.chat_id)
end
end

end -- end admin


if redis:get('checkdone'..msg.chat_id) then

if is_owner(msg) then

if text:match("^[Ss][Ee][Tt][Aa][Uu][Tt][Oo][Ll][Oo][Cc][Kk]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
redis:setex("atolc"..msg.chat_id..msg.sender_user_id,45,true)
if redis:get("atolct1"..msg.chat_id) and redis:get("atolct2"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• لطفا زمان مورد نظر برای قفل شدن گروه را وارد کنید !\n\n» برای مثال : 17:30\n\n• Ch : '..channel..'', 'md')
redis:del("atolct1"..msg.chat_id)
redis:del("atolct2"..msg.chat_id)
redis:del("lc_ato:"..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '• لطفا زمان مورد نظر برای قفل شدن گروه را وارد کنید !\n\n» برای مثال : 17:30\n\n• Ch : '..channel..'', 'md')
end
elseif text:match("^[Rr][Ee][Mm][Aa][Uu][Tt][Oo][Ll][Oo][Cc][Kk]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get("atolct1"..msg.chat_id) and redis:get("atolct2"..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• زمان وارد شده شما برای قفل خودکار گروه حذف شد !\n\n• Ch : '..channel..'', 'md')
redis:del("atolct1"..msg.chat_id)
redis:del("atolct2"..msg.chat_id)
redis:del("lc_ato:"..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '• زمان وارد شده شما برای قفل خودکار گروه حذف شد !\n\n• Ch : '..channel..'', 'md')
end
elseif text:match("^[Aa][Uu][Tt][Oo][Ll][Oo][Cc][Kk] [Ss][Tt][Aa][Tt][Ss]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local t1 = redis:get("atolct1"..msg.chat_id)
local t2 = redis:get("atolct2"..msg.chat_id)
if t1 and t2 then
local lc = redis:get("lc_ato:"..msg.chat_id)
if lc then
stats = "فعال"
else
stats = "غیرفعال"
end
sendText(msg.chat_id, msg.id, '• قفل خودکار گروه در حال حاضر [ '..stats..' ] میباشد !\n\n» ارسال پیام در گروه در ساعت  [ <code>'..t1..'</code> ]  ممنوع و در ساعت  [ <code>'..t2..'</code> ]  آزاد خواهد شد .\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• در حال حاضر زمانی برای قفل خودکار تایین نشده است !\n\n» برای ثبت زمان از دستور\n`Setautolock`\nاستفاده کنید .\n\n• Ch : '..channel..'', 'md')
end
elseif text:match("^%d+%d+:%d+%d+$") and redis:get("atolc"..msg.chat_id..msg.sender_user_id) then
local ap = {string.match(text, "^(%d+%d+:)(%d+%d+)$")}
local h = text:match("%d+%d+:")
h = h:gsub(":", "")
local m = text:match(":%d+%d+")
m = m:gsub(":", "")
local hh = 23
local mm = 59
if hh >= tonumber(h) and mm >= tonumber(m) then
local hour = tonumber(h)
local mine = tonumber(m)
local noh = 9
if noh >= tonumber(h) then
hourr1 = '0'..hour
else
hourr1 = hour
end
if noh >= tonumber(m) then
minee1 = '0'..mine
else
minee1 = mine
end
sendText(msg.chat_id, msg.id, '• زمان اولیه برای قفل خودکار گروه ثبت شد !\n\n» لطفا دومین زمان برای باز شدن خودکار گروه را وارد کنید .\n\n• Ch : '..channel..'', 'html')
redis:del("atolc"..msg.chat_id..msg.sender_user_id)
redis:setex("atolct1"..msg.chat_id, 45, hourr1..':'..minee1)
redis:setex("atolc2"..msg.chat_id..msg.sender_user_id, 45, true)
else
sendText(msg.chat_id, msg.id, '• زمان ارسالی صحیح نمیباشد !', 'md')
end
elseif text:match("^%d+%d+:%d+%d+$") and redis:get("atolc2"..msg.chat_id..msg.sender_user_id)  then
local time_1 = redis:get("atolct1"..msg.chat_id)
local ap = {string.match(text, "^(%d+%d+):(%d+%d+)$")}
local h = text:match("%d+%d+:")
h = h:gsub(":", "")
local m = text:match(":%d+%d+")
m = m:gsub(":", "")
local hh = 23
local mm = 59
if time_1 == tonumber(h)..':'..tonumber(m) then
sendText(msg.chat_id, msg.id, '• زمان آغاز قفل خودکار نمیتواند با زمان پایان آن یکی باشد !', 'html')
else
if hh >= tonumber(h) and mm >= tonumber(m) then
local hour = tonumber(h)
local mine = tonumber(m)
local noh = 9
if noh >= tonumber(h) then
hourr = '0'..hour
else
hourr = hour
end
if noh >= tonumber(m) then
minee = '0'..mine
else
minee = mine
end
sendText(msg.chat_id, msg.id, '• ثبت زمان قفل خودکار با موفقیت انجام شد !\n\n» گروه در ساعت [ <code>'..hourr1..':'..minee1..'</code> ] قفل و در ساعت [ <code>'..hourr..':'..minee..'</code> ] باز خواهد شد !\n\n• Ch : '..channel..'', 'html')
redis:set("atolct1"..msg.chat_id,redis:get("atolct1"..msg.chat_id))
redis:set("atolct2"..msg.chat_id,hourr..':'..minee)
redis:del("atolc2"..msg.chat_id..msg.sender_user_id)
else
sendText(msg.chat_id, msg.id, '• زمان ارسالی صحیح نمیباشد !', 'md')
end
end
end

if text:match("^[Cc][Oo][Nn][Ff][Ii][Gg]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local function GetCreator(extra, result, success)
for k,v in pairs(result.members) do
if v.status._ == "chatMemberStatusCreator" then
local addmins = tonumber(result.total_count) -1
local function name(arg, data, success)
if data.username ~= '' then
username = '<code>'..v.user_id..'</code> - @'..data.username..''
else
username = '<code>'..v.user_id..'</code> - <a href="tg://user?id='..v.user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• کاربر [ '..username..' ] به عنوان مالک گروه تنظیم شد !\n\n» ( '..addmins..' ) ادمین شناسایی شده با موفقیت ترفیع یافتند .\n\n• Ch : '..channel..'', 'html')
end
redis:sadd('owners'..msg.chat_id, v.user_id)
getUser(v.user_id, name, nil)
end
end
for p,t in pairs(result.members) do
if t.status._== "chatMemberStatusAdministrator" then
redis:sadd('mods'..msg.chat_id, t.user_id)
end
end
end
getChannelMembers(msg.chat_id, 'Administrators' , 0, 200, GetCreator)
end

if (text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk] ([https?://w]*.?telegram.me/joinchat/.*)$") or text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk] ([https?://w]*.?t.me/joinchat/.*)$")) and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local link = text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk] ([https?://w]*.?telegram.me/joinchat/.*)$") or text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk] ([https?://w]*.?t.me/joinchat/.*)$")
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• لینک ارائه شده با موفقیت ثبت شد !\n\n» لینک ارائه شده :\n» { '..link..' }\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('link'..msg.chat_id, link)
end

if text:match('^[Rr][Ee][Mm][Ll][Ii][Nn][Kk]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• لینک ثبت شده با موفقیت حذف شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:del('link'..msg.chat_id)
end

if text:match('^[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local rules = text:match('[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)')
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• قوانین ارائه شده با موفقیت ثبت شدند !\n\n» قوانین ارائه شده :\n» { '..rules..' }\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('rules'..msg.chat_id, rules)
end

if text:match('^[Rr][Ee][Mm][Rr][Uu][Ll][Ee][Ss]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• قوانین ثبت شده با موفقیت حذف شدند !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:del('rules'..msg.chat_id)
end

if text:match('^[Ww][Ee][Ll][Cc][Oo][Mm][Ee] [Ee][Nn][Aa][Bb][Ll][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• ارسال پیام خوشامدگویی فعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('welcome'..msg.chat_id, 'enable')
end

if text:match('^[Ww][Ee][Ll][Cc][Oo][Mm][Ee] [Dd][Ii][Ss][Aa][Bb][Ll][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• ارسال پیام خوشامدگویی غیرفعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('welcome'..msg.chat_id, 'disable')
end

if text:match('^[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local welcome = text:match('^[Ss][Ee][Tt][Ww][Ee][Ll][Cc][Oo][Mm][Ee] (.*)')
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• پیام خوشامد گویی با موفقیت ثبت شد .\n\n» پیام خوشامد گویی :\n» { '..welcome..' }\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('welcome:'..msg.chat_id, welcome)
end

if text:match('^[Rr][Ee][Mm][Ww][Ee][Ll][Cc][Oo][Mm][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code>'
end
sendText(msg.chat_id, msg.id, '• پیام خوشامدگویی با موفقیت حذف و به حالت اولیه بازگشت !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:del('welcome:'..msg.chat_id, welcome)
end

if text:match('^[Pp][Rr][Oo][Mm][Oo][Tt][Ee]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function SetMod(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
Promote(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, SetMod)
end

if text:match('^[Pp][Rr][Oo][Mm][Oo][Tt][Ee] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
Promote(msg, msg.chat_id, id)
end

if text:match('^[Pp][Rr][Oo][Mm][Oo][Tt][Ee] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Pp][Rr][Oo][Mm][Oo][Tt][Ee] @(.*)$')
function modusername(extra,result,success)
if result.id then
Promote(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, modusername)
end

if text:match('^[Pp][Rr][Oo][Mm][Oo][Tt][Ee] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
Promote(msg, msg.chat_id, text:match('^[Pp][Rr][Oo][Mm][Oo][Tt][Ee] (%d+)$'))
end

if text:match('^[Dd][Ee][Mm][Oo][Tt][Ee]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function RemMod(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
Demote(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, RemMod)
end

if text:match('^[Dd][Ee][Mm][Oo][Tt][Ee] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
Demote(msg, msg.chat_id, id)
end

if text:match('^[Dd][Ee][Mm][Oo][Tt][Ee] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Dd][Ee][Mm][Oo][Tt][Ee] @(.*)$')
function remmodusername(extra,result,success)
if result.id then
Demote(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, remmodusername)
end

if text:match('^[Dd][Ee][Mm][Oo][Tt][Ee] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
Demote(msg, msg.chat_id, text:match('^[Dd][Ee][Mm][Oo][Tt][Ee] (%d+)$'))
end

if text:match('^[Mm][Oo][Dd][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('mods'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مدیران گروه خالی میباشد !', 'md')
else
local txt = '» لیست مدیران گروه :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Mm][Oo][Dd][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
list = redis:smembers('mods'..msg.chat_id)
num = redis:scard('mods'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست مدیران گروه خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست مدیران گروه پاکسازی شد !\n\n» تعداد مدیران : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('mods'..msg.chat_id)
end
end

if text:match('^[Ss][Ee][Tt][Vv][Ii][Pp]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function setvip(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
Vip(msg,msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, setvip)
end

if text:match('^[Ss][Ee][Tt][Vv][Ii][Pp] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
Vip(msg,msg.chat_id, id)
end

if text:match('^[Ss][Ee][Tt][Vv][Ii][Pp] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Ss][Ee][Tt][Vv][Ii][Pp] @(.*)$')
function vipusername(extra,result,success)
if result.id then
Vip(msg,msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, vipusername)
end

if text:match('^[Ss][Ee][Tt][Vv][Ii][Pp] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
Vip(msg,msg.chat_id,text:match('^[Ss][Ee][Tt][Vv][Ii][Pp] (%d+)$'))
end

if text:match('^[Rr][Ee][Mm][Vv][Ii][Pp]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function remvip(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
RemVip(msg,msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, msg.reply_to_message_id, remvip)
end

if text:match('^[Rr][Ee][Mm][Vv][Ii][Pp] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
RemVip(msg,msg.chat_id, id)
end

if text:match('^[Rr][Ee][Mm][Vv][Ii][Pp] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Rr][Ee][Mm][Vv][Ii][Pp] @(.*)$')
function vipusername(extra,result,success)
if result.id then
RemVip(msg,msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, vipusername)
end

if text:match('^[Rr][Ee][Mm][Vv][Ii][Pp] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
RemVip(msg,msg.chat_id,text:match('^[Rr][Ee][Mm][Vv][Ii][Pp] (%d+)$'))
end

if text:match('^[Vv][Ii][Pp][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('vips'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران ویژه خالی میباشد !', 'md')
else
local txt = '» لیست کاربران ویژه :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Vv][Ii][Pp][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
list = redis:smembers('vips'..msg.chat_id)
num = redis:scard('vips'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران ویژه خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست کاربران ویژه پاکسازی شد !\n\n» تعداد کاربران : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('vips'..msg.chat_id)
end
end

if text:match('^[Ss][Ee][Tt][Ww][Aa][Rr][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local num = tonumber(text:match('^[Ss][Ee][Tt][Ww][Aa][Rr][Nn] (%d+)$'))
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
if num < 3 then
sendText(msg.chat_id, msg.id, '• حداقل مقدار اخطار باید بیشتر از 2 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
elseif num > 10 then
sendText(msg.chat_id, msg.id, '• حداکثر مقدار اخطار باید کمتر از 10 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• سقف مجاز اخطار با موفقیت تنظیم شد !\n\n» تعداد مجاز : [ <code>'..num..'</code> ]\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:hset("warn"..msg.chat_id, "warnmax" , num)
end
end

end -- end owner


if is_mod(msg) then

if text:match('^[Ll][Oo][Cc][Kk] [Ff][Ll][Oo][Oo][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• قفل رگبار با موفقیت فعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:hset("flooding:settings:"..msg.chat_id,"flood",'ban')
end

if text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ff][Ll][Oo][Oo][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• قفل رگبار با موفقیت غیرفعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:hdel("flooding:settings:"..msg.chat_id,"flood")
end

if text:match('^[Ll][Oo][Cc][Kk] [Ll][Ii][Nn][Kk]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('link'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل لینک در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل لینک با موفقیت فعال شد ._' , 'md')
redis:set('link'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ll][Ii][Nn][Kk]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('link'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل لینک با موفقیت غیرفعال شد ._' , 'md')
redis:del('link'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل لینک در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Ff][Oo][Rr][Ww][Aa][Rr][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('forward'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فوروارد در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فوروارد با موفقیت فعال شد ._' , 'md')
redis:set('forward'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ff][Oo][Rr][Ww][Aa][Rr][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('forward'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فوروارد با موفقیت غیرفعال شد ._' , 'md')
redis:del('forward'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فوروارد در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('username'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل یوزرنیم در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل یوزرنیم با موفقیت فعال شد ._' , 'md')
redis:set('username'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Uu][Ss][Ee][Rr][Nn][Aa][Mm][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('username'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل یوزرنیم با موفقیت غیرفعال شد ._' , 'md')
redis:del('username'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل یوزرنیم در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Hh][Aa][Ss][Hh][Tt][Aa][Gg]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('hashtag'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل هشتگ در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل هشتگ با موفقیت فعال شد ._' , 'md')
redis:set('hashtag'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Hh][Aa][Ss][Hh][Tt][Aa][Gg]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('hashtag'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل هشتگ با موفقیت غیرفعال شد ._' , 'md')
redis:del('hashtag'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل هشتگ در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Pp][Ee][Rr][Ss][Ii][Aa][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('persian'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فارسی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فارسی با موفقیت فعال شد ._' , 'md')
redis:set('persian'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Pp][Ee][Rr][Ss][Ii][Aa][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('persian'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فارسی با موفقیت غیرفعال شد ._' , 'md')
redis:del('persian'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فارسی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Ee][Nn][Gg][Ll][Ii][Ss][Hh]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('english'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل انگلیسی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل انگلیسی با موفقیت فعال شد ._' , 'md')
redis:set('english'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ee][Nn][Gg][Ll][Ii][Ss][Hh]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('english'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل انگلیسی با موفقیت غیرفعال شد ._' , 'md')
redis:del('english'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل انگلیسی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Bb][Aa][Dd][Ww][Oo][Rr][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('badword'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فحش در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فحش با موفقیت فعال شد ._' , 'md')
redis:set('badword'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Bb][Aa][Dd][Ww][Oo][Rr][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('badword'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فحش با موفقیت غیرفعال شد ._' , 'md')
redis:del('badword'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فحش در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Bb][Oo][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('bot'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل ربات در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل ربات با موفقیت فعال شد ._' , 'md')
redis:set('bot'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Bb][Oo][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('bot'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل ربات با موفقیت غیرفعال شد ._' , 'md')
redis:del('bot'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل ربات در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Jj][Oo][Ii][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('join'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل ورودی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل ورودی با موفقیت فعال شد ._' , 'md')
redis:set('join'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Jj][Oo][Ii][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('join'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل ورودی با موفقیت غیرفعال شد ._' , 'md')
redis:del('join'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل ورودی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Cc][Mm][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('cmd'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل دستورات در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل دستورات با موفقیت فعال شد ._' , 'md')
redis:set('cmd'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Cc][Mm][Dd]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('cmd'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل دستورات با موفقیت غیرفعال شد ._' , 'md')
redis:del('cmd'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل دستورات در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Tt][Gg][Ss][Ee][Rr][Vv][Ii][Cc][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('tgservice'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل پیام سرویسی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل پیام سرویسی با موفقیت فعال شد ._' , 'md')
redis:set('tgservice'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Tt][Gg][Ss][Ee][Rr][Vv][Ii][Cc][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('tgservice'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل پیام سرویسی با موفقیت غیرفعال شد ._' , 'md')
redis:del('tgservice'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل پیام سرویسی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Tt][Ee][Xx][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('text'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل متن در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل متن با موفقیت فعال شد ._' , 'md')
redis:set('text'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Tt][Ee][Xx][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('text'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل متن با موفقیت غیرفعال شد ._' , 'md')
redis:del('text'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل متن در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Gg][Ii][Ff]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('gif'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل گیف در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل گیف با موفقیت فعال شد ._' , 'md')
redis:set('gif'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Gg][Ii][Ff]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('gif'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل گیف با موفقیت غیرفعال شد ._' , 'md')
redis:del('gif'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل گیف در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Cc][Oo][Nn][Tt][Aa][Cc][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('contact'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل مخاطب در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل مخاطب با موفقیت فعال شد ._' , 'md')
redis:set('contact'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Cc][Oo][Nn][Tt][Aa][Cc][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('contact'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل مخاطب با موفقیت غیرفعال شد ._' , 'md')
redis:del('contact'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل مخاطب در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Pp][Hh][Oo][Tt][Oo]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('photo'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل عکس در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل عکس با موفقیت فعال شد ._' , 'md')
redis:set('photo'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Pp][Hh][Oo][Tt][Oo]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('photo'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل عکس با موفقیت غیرفعال شد ._' , 'md')
redis:del('photo'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل عکس در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Vv][Ii][Dd][Ee][Oo]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('video'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فیلم در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فیلم با موفقیت فعال شد ._' , 'md')
redis:set('video'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Vv][Ii][Dd][Ee][Oo]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('video'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فیلم با موفقیت غیرفعال شد ._' , 'md')
redis:del('video'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فیلم در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Vv][Oo][Ii][Cc][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('voice'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل صدا در حال حاضر فعال است !_', 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل صدا با موفقیت فعال شد ._' , 'md')
redis:set('voice'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Vv][Oo][Ii][Cc][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('voice'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل صدا با موفقیت غیرفعال شد ._' , 'md')
redis:del('voice'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل صدا در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Mm][Uu][Ss][Ii][Cc]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('music'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل آهنگ در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل آهنگ با موفقیت فعال شد ._' , 'md')
redis:set('music'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Mm][Uu][Ss][Ii][Cc]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('music'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل آهنگ با موفقیت غیرفعال شد ._' , 'md')
redis:del('music'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل آهنگ در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Gg][Aa][Mm][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('game'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل بازی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل بازی با موفقیت فعال شد ._' , 'md')
redis:set('game'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Gg][Aa][Mm][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('game'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل بازی با موفقیت غیرفعال شد ._' , 'md')
redis:del('game'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل بازی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Ss][Tt][Ii][Cc][Kk][Ee][Rr]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('sticker'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل استیکر در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل استیکر با موفقیت فعال شد ._' , 'md')
redis:set('sticker'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ss][Tt][Ii][Cc][Kk][Ee][Rr]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('sticker'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل استیکر با موفقیت غیرفعال شد ._' , 'md')
redis:del('sticker'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل استیکر در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('document'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فایل در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فایل با موفقیت فعال شد ._' , 'md')
redis:set('document'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Dd][Oo][Cc][Uu][Mm][Ee][Nn][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('document'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فایل با موفقیت غیرفعال شد ._' , 'md')
redis:del('document'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فایل در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Ii][Nn][Ll][Ii][Nn][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('inline'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل اینلاین در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل اینلاین با موفقیت فعال شد ._' , 'md')
redis:set('inline'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ii][Nn][Ll][Ii][Nn][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('inline'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل اینلاین با موفقیت غیرفعال شد ._' , 'md')
redis:del('inline'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل اینلاین در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Vv][Ii][Dd][Ee][Oo][Nn][Oo][Tt][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('videonote'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فیلم سلفی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل فیلم سلفی با موفقیت فعال شد ._' , 'md')
redis:set('videonote'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Vv][Ii][Dd][Ee][Oo][Nn][Oo][Tt][Ee]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('videonote'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل فیلم سلفی با موفقیت غیرفعال شد ._' , 'md')
redis:del('videonote'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل فیلم سلفی در حال حاضر غیرفعال است !_' , 'md')
end
end

if text:match('^[Ll][Oo][Cc][Kk] [Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('location'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل موقعیت مکانی در حال حاضر فعال است !_' , 'md')
else
sendText(msg.chat_id, msg.id, '_» قفل موقعیت مکانی با موفقیت فعال شد ._' , 'md')
redis:set('location'..msg.chat_id, true)
end
elseif text:match('^[Uu][Nn][Ll][Oo][Cc][Kk] [Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('location'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '_» قفل موقعیت مکانی با موفقیت غیرفعال شد ._' , 'md')
redis:del('location'..msg.chat_id)
else
sendText(msg.chat_id, msg.id, '_» قفل موقعیت مکانی در حال حاضر غیرفعال است !_' , 'md')
end
end


if text:match("^[Cc][Ll][Ee][Aa][Nn] [Bb][Oo][Tt][Ss]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local function cbots(extra, result, success)
if result.total_count == 0 then
sendText(msg.chat_id, msg.id, '• در حال حاضر رباتی در گروه وجود ندارد !', 'html')
else
for i=0 , #result.members do
kicck(msg, msg.chat_id, result.members[i].user_id)
end
sendText(msg.chat_id, msg.id, '• ربات های موجود درگروه با موفقیت حذف شدند !\n\n» تعداد ربات ها : [ <code>'..result.total_count..'</code> ]\n\n• Ch : '..channel..'', 'html')
end
end
getChannelMembers(msg.chat_id, "Bots", 0, 200, cbots, nil)
end

if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Ss][Tt][Rr][Ii][Cc][Tt][Ee][Ss]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local function resss(extra, result, success)
for k,v in pairs(result.members) do
muteres(msg.chat_id, v.user_id, 'Restricted', {1, 1, 1, 1, 1,1})
end
sendText(msg.chat_id, msg.id,'• کاربران محدود شده با موفقیت ازاد شدند !\n\n• Ch : '..channel..'' ,'md')
end
getChannelMembers(msg.chat_id, "Recent", 0, 200, resss)
end

if text:match('^[Ww][Aa][Rr][Nn]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
local function Warnn(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
Warn(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), Warnn)
end

if text:match('^[Ww][Aa][Rr][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
Warn(msg, msg.chat_id, id)
end

if text:match('^[Ww][Aa][Rr][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('^[Ww][Aa][Rr][Nn] @(.*)$')
function warnusername(extra,result,success)
if result.id then
Warn(msg,msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, warnusername)
end

if text:match('^[Ww][Aa][Rr][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
Warn(msg,msg.chat_id,text:match('[Ww][Aa][Rr][Nn] (%d+)'))
end

if text:match('^[Rr][Ee][Mm][Ww][Aa][Rr][Nn]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
local function RemWarnn(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
Remwarn(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), RemWarnn)
end

if text:match('^[Rr][Ee][Mm][Ww][Aa][Rr][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
Remwarn(msg, msg.chat_id, id)
end

if text:match('^[Rr][Ee][Mm][Ww][Aa][Rr][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('^[Rr][Ee][Mm][Ww][Aa][Rr][Nn] @(.*)$')
function unwarnusername(extra,result,success)
if result.id then
Remwarn(msg,msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..username..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, unwarnusername)
end

if text:match('^[Rr][Ee][Mm][Ww][Aa][Rr][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
Remwarn(msg,msg.chat_id,text:match('[Rr][Ee][Mm][Ww][Aa][Rr][Nn] (%d+)'))
end

if text:match('^[Ww][Aa][Rr][Nn][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:hkeys('warn'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربرانی که اخطار دریافت کرده اند خالی میباشد !', 'md')
else
local txt = '» لیست کاربرانی که اخطار دریافت کرده اند :\n\n'
for k,v in pairs(list) do
local cont = redis:hget('warn'..msg.chat_id, v) or 0
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' - ('..cont..') ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Ww][Aa][Rr][Nn][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
list = redis:hkeys('warn'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربرانی که اخطار دریافت کرده اند خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست کاربرانی که اخطار دریافت کرده اند پاکسازی شد !\n\n• Ch : '..channel..'', 'md')
redis:del('warn'..msg.chat_id)
end
end

local function getsettings(value)
if value == 'muteall' then
local hash = redis:get('muteall'..msg.chat_id)
if hash then
return '( فعال|🔐 )'
else
return '( غيرفعال|🔓 )'
end
elseif value == 'welcome' then
local hash = redis:get('welcome'..msg.chat_id)
if hash == 'enable' then
return '( فعال )'
else
return '( غيرفعال )'
end
elseif value == 'spam' then
local hash = redis:hget("flooding:settings:"..msg.chat_id,"flood")
if hash then
if redis:hget("flooding:settings:"..msg.chat_id,"flood") == "ban" then
return '( فعال|🔐 )'
end
else
return '( غيرفعال|🔓 )'
end
end
end

if text:match('^[Ss][Ee][Tt][Tt][Ii][Nn][Gg][Ss]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
if redis:get('link'..msg.chat_id) then
Link = '( فعال|🔐 )'
else
Link = '( غيرفعال|🔓 )'
end
if redis:get('forward'..msg.chat_id) then
Forward = '( فعال|🔐 )'
else
Forward = '( غيرفعال|🔓 )'
end
if redis:get('username'..msg.chat_id) then
Username = '( فعال|🔐 )'
else
Username = '( غيرفعال|🔓 )'
end
if redis:get('hashtag'..msg.chat_id) then
Hashtag = '( فعال|🔐 )'
else
Hashtag = '( غيرفعال|🔓 )'
end
if redis:get('persian'..msg.chat_id) then
Persian = '( فعال|🔐 )'
else
Persian = '( غيرفعال|🔓 )'
end
if redis:get('english'..msg.chat_id) then
English = '( فعال|🔐 )'
else
English = '( غيرفعال|🔓 )'
end
if redis:get('badword'..msg.chat_id) then
Badword = '( فعال|🔐 )'
else
Badword = '( غيرفعال|🔓 )'
end
if redis:get('bot'..msg.chat_id) then
Bot = '( فعال|🔐 )'
else
Bot = '( غيرفعال|🔓 )'
end
if redis:get('join'..msg.chat_id) then
Join = '( فعال|🔐 )'
else
Join = '( غيرفعال|🔓 )'
end
if redis:get('cmd'..msg.chat_id) then
Cmd = '( فعال|🔐 )'
else
Cmd = '( غيرفعال|🔓 )'
end
if redis:get('tgservice'..msg.chat_id) then
Tgservice = '( فعال|🔐 )'
else
Tgservice = '( غيرفعال|🔓 )'
end
if redis:get('text'..msg.chat_id) then
Text = '( فعال|🔐 )'
else
Text = '( غيرفعال|🔓 )'
end
if redis:get('gif'..msg.chat_id) then
Gif = '( فعال|🔐 )'
else
Gif = '( غيرفعال|🔓 )'
end
if redis:get('contact'..msg.chat_id) then
Contact = '( فعال|🔐 )'
else
Contact = '( غيرفعال|🔓 )'
end
if redis:get('photo'..msg.chat_id) then
Photo = '( فعال|🔐 )'
else
Photo = '( غيرفعال|🔓 )'
end
if redis:get('video'..msg.chat_id) then
Video = '( فعال|🔐 )'
else
Video = '( غيرفعال|🔓 )'
end
if redis:get('voice'..msg.chat_id) then
Voice = '( فعال|🔐 )'
else
Voice = '( غيرفعال|🔓 )'
end
if redis:get('music'..msg.chat_id) then
Music = '( فعال|🔐 )'
else
Music = '( غيرفعال|🔓 )'
end
if redis:get('game'..msg.chat_id) then
Game = '( فعال|🔐 )'
else
Game = '( غيرفعال|🔓 )'
end
if redis:get('sticker'..msg.chat_id) then
Sticker = '( فعال|🔐 )'
else
Sticker = '( غيرفعال|🔓 )'
end
if redis:get('document'..msg.chat_id) then
Document = '( فعال|🔐 )'
else
Document = '( غيرفعال|🔓 )'
end
if redis:get('inline'..msg.chat_id) then
Inline = '( فعال|🔐 )'
else
Inline = '( غيرفعال|🔓 )'
end
if redis:get('videonote'..msg.chat_id) then
Videonote = '( فعال|🔐 )'
else
Videonote = '( غيرفعال|🔓 )'
end
if redis:get('location'..msg.chat_id) then
Location = '( فعال|🔐 )'
else
Location = '( غيرفعال|🔓 )'
end
local t1 = redis:get("atolct1"..msg.chat_id)
local t2 = redis:get("atolct2"..msg.chat_id)
if t1 and t2 then
timelock = '<code>'..t1..'</code> - <code>'..t2..'</code>'
else
timelock = '------'
end
local lc = redis:get("lc_ato:"..msg.chat_id)
if lc then
stats = "فعال|🔐"
else
stats = "غيرفعال|🔓"
end
local wmax = tonumber(redis:hget("warn"..msg.chat_id,"warnmax") or 3)
local text = '• تنظیمات گروه مدیریتی عبارتند از :\n\n'
..'» قفل لینک : '..Link..'\n'
..'» قفل فوروارد : '..Forward..'\n\n'
..'» قفل یوزرنیم : '..Username..'\n'
..'» قفل هشتگ : '..Hashtag..'\n\n'
..'» قفل فارسی : '..Persian..'\n'
..'» قفل انگلیسی : '..English..'\n\n'
..'» قفل فحش : '..Badword..'\n'
..'» قفل ربات : '..Bot..'\n\n'
..'» قفل ورودی : '..Join..'\n'
..'» قفل دستورات : '..Cmd..'\n\n'
..'» قفل گیف : '..Gif..'\n'
..'» قفل مخاطب : '..Contact..'\n\n'
..'» قفل عکس : '..Photo..'\n'
..'» قفل فیلم : '..Video..'\n\n'
..'» قفل صدا : '..Voice..'\n'
..'» قفل آهنگ : '..Music..'\n\n'
..'» قفل بازی : '..Game..'\n'
..'» قفل استیکر : '..Sticker..'\n\n'
..'» قفل متن : '..Text..'\n'
..'» قفل فایل : '..Document..'\n\n'
..'» قفل اینلاین : '..Inline..'\n'
..'» قفل فیلم سلفی : '..Videonote..'\n\n'
..'» قفل پیام سرویسی : '..Tgservice..'\n'
..'» قفل موقعیت مکانی : '..Location..'\n\n'
..'» قفل رگبار : '..getsettings('spam')..'\n'
..'» مقدار ارسال رگبار : ( <code>10/'..NUM_MSG_MAX..'</code> )\n'
..'» زمان حساسیت رگبار : ( <code>10/'..TIME_CHECK..'</code> )\n\n'
..'» قفل چت : '..getsettings('muteall')..'\n'
..'» وضعیت قفل خودکار : ( '..stats..' )\n'
..'» ساعات تعطیلی گروه : ( '..timelock..' )\n\n'
..'» حداکثر اخطار : ( <code>10/'..wmax..'</code> )\n'
..'» خوشامدگویی : '..getsettings('welcome')..'\n'
.."» آیدی عددی گروه : ( <code>"..msg.chat_id.."</code> )\n\n"
.."• Ch : '..channel..'"
sendText(msg.chat_id, msg.id, text, 'html')
end

if text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Mm][Aa][Xx] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local reac = tonumber(text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Mm][Aa][Xx] (%d+)$'))
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
if reac < 3 then
sendText(msg.chat_id, msg.id, '• حداقل مقدار ارسال پیام مکرر باید بزرگ تر از 2 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
elseif reac > 10 then
sendText(msg.chat_id, msg.id, '• حداکثر مقدار ارسال پیام مکرر باید کوچکتر از 10 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• مقدار ارسال پیام های مکرر با موفقیت تنظیم شد .\n\n» مقدار تنظیم شده : [ '..reac..' ]\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:hset("flooding:settings:"..msg.chat_id,"floodmax" ,text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Mm][Aa][Xx] (%d+)$'))
end
end

if text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Tt][Ii][Mm][Ee] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local reac = tonumber(text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Tt][Ii][Mm][Ee] (%d+)$'))
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
if reac < 3 then
sendText(msg.chat_id, msg.id, '• حداقل زمان ارسال پیام مکرر باید بزرگ تر از 2 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
elseif reac > 10 then
sendText(msg.chat_id, msg.id, '• حداکثر زمان ارسال پیام مکرر باید کوچکتر از 10 باشد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• زمان ارسال پیام های مکرر با موفقیت تنظیم شد .\n\n» زمان تنظیم شده : [ '..reac..' ]\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:hset("flooding:settings:"..msg.chat_id,"floodtime" ,text:match('^[Ss][Ee][Tt][Ff][Ll][Oo][Oo][Dd][Tt][Ii][Mm][Ee] (%d+)$'))
end
end

if text:match('^[Mm][Uu][Tt][Ee][Aa][Ll][Ll]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
if redis:get('muteall'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• قفل گروه درحال حاضر فعال است !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• قفل گروه با موفقیت فعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:set('muteall'..msg.chat_id,true)
end
end

if text:match('^[Uu][Nn][Mm][Uu][Tt][Ee][Aa][Ll][Ll]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
if not redis:get('muteall'..msg.chat_id) then
sendText(msg.chat_id, msg.id, '• قفل گروه درحال حاضر غیرفعال است !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• قفل گروه با موفقیت غیرفعال شد !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
redis:del('muteall'..msg.chat_id)
end
end

if text:match('^[Kk][Ii][Cc][Kk]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function kick_by_reply(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
kick(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), kick_by_reply)
end

if text:match('^[Kk][Ii][Cc][Kk] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
kick(msg, msg.chat_id, id)
end

if text:match('^[Kk][Ii][Cc][Kk] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Kk][Ii][Cc][Kk] @(.*)$')
function kick_username(extra,result,success)
if result.id then
kick(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..text:match('^[Kk][Ii][Cc][Kk] @(.*)$')..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, kick_username)
end

if text:match('^[Kk][Ii][Cc][Kk] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
kick(msg, msg.chat_id, text:match('^[Kk][Ii][Cc][Kk] (%d+)$'))
end

if text:match('^[Bb][Aa][Nn]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function banreply(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
ban(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), banreply)
end

if text:match('^[Bb][Aa][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
ban(msg, msg.chat_id, id)
end

if text:match('^[Bb][Aa][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Bb][Aa][Nn] @(.*)$')
function banusername(extra,result,success)
if result.id then
ban(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..text:match('^[Bb][Aa][Nn] @(.*)')..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, banusername)
end

if text:match('^[Bb][Aa][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
ban(msg, msg.chat_id,text:match('^[Bb][Aa][Nn] (%d+)$'))
end

if text:match('^[Uu][Nn][Bb][Aa][Nn]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function unbanreply(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
unban(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), unbanreply)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
unban(msg, msg.chat_id, id)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('^[Uu][Nn][Bb][Aa][Nn] @(.*)$')
function unbanusername(extra,result,success)
if result.id then
unban(msg,msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..text:match('^[Uu][Nn][Bb][Aa][Nn] @(.*)')..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, unbanusername)
end

if text:match('^[Uu][Nn][Bb][Aa][Nn] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
unban(msg, msg.chat_id,text:match('^[Uu][Nn][Bb][Aa][Nn] (%d+)$'))
end

if text:match('^[Bb][Aa][Nn][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('banned'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران مسدود شده خالی میباشد !', 'md')
else
local txt = '» لیست کاربران مسدود شده :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Bb][Aa][Nn][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('banned'..msg.chat_id)
local num = redis:scard('banned'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران مسدود شده خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• لیست کاربران مسدود شده پاکسازی شد !\n\n» تعداد کاربران : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('banned'..msg.chat_id)
end
end

if text:match('^[Ss][Ii][Ll][Ee][Nn][Tt]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function mutereply(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
mute(msg, msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), mutereply)
end

if text:match('^[Ss][Ii][Ll][Ee][Nn][Tt] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
mute(msg, msg.chat_id, id)
end

if text:match('^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)')
function muteusername(extra,result,success)
if result.id then
mute(msg, msg.chat_id, result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..text:match('^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)')..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, muteusername)
end

if text:match('^[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
mute(msg, msg.chat_id,text:match('[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)'))
end

if text:match('^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
function unmutereply(extra, result, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
unmute(msg,msg.chat_id, result.sender_user_id)
end
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), unmutereply)
end

if text:match('^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (.*)$') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
unmute(msg, msg.chat_id, id)
end

if text:match('^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local username = text:match('[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)')
function unmuteusername(extra,result,success)
if result.id then
unmute(msg, msg.chat_id,result.id)
else
sendText(msg.chat_id, msg.id, '• کاربر [ @'..text:match('^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)')..' ] یافت نشد !', 'html')
end
end
searchPublicChat(username, unmuteusername)
end

if text:match('^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
unmute(msg,msg.chat_id,text:match('[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)'))
end

if text:match('^[Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('mutes'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران در حالت سکوت خالی میباشد !', 'md')
else
local txt = '» لیست کاربران در حالت سکوت  :\n\n'
for k,v in pairs(list) do
local usrname = redis:get('usrname'..v)
if usrname then
username = '@'..usrname..' - <code>'..v..'</code>'
else
username = '<a href="tg://user?id='..v..'">» Click «</a> - <code>'..v..'</code>'
end
txt = txt..k..' - [ '..username..' ]\n'
end
sendText(msg.chat_id, msg.id, txt, 'html')
end
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('mutes'..msg.chat_id)
local num = redis:scard('mutes'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست کاربران در حالت سکوت خالی میباشد !', 'md')
else
sendText(msg.chat_id, msg.id, '• کاربرانی که در حالت سکوت بودند آزاد شدند !\n\n» تعداد کاربران : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('mutes'..msg.chat_id)
end
end

if text:match('^[Dd][Ee][Ll] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local limit = tonumber(text:match('^[Dd][Ee][Ll] (%d+)$'))
if limit > 100 then
sendText(msg.chat_id, msg.id, '• شما در هربار پاکسازی میتوانید صد پیام را پاکسازی کنید !', 'md')
elseif limit < 1 then
sendText(msg.chat_id, msg.id, '• لطفا عددی بزرگ تر از صفر به کار ببرید !', 'md')
else
function cb(extra, result, success)
local msagge = result.messages
for i=1 , #msagge do
deleteMessages(msg.chat_id,{[0] = msagge[i].id})
end
end
getChatHistory(msg.chat_id, msg.id, 0, limit+2, cb, nil)
sendText(msg.chat_id, msg.id, 'تعداد درخواستی پیام ها با موفقیت حذف شدند !\n\nتعداد پیام ها : [ <code>'..limit..'</code> ]\n\n• Ch : '..channel..'', 'html')
end
end

if text:match('^[Dd][Ee][Ll]$') and tonumber(msg.reply_to_message_id) > 0 then
deleteMessages(msg.chat_id,{[0] =  tonumber(msg.reply_to_message_id)})
deleteMessages(msg.chat_id,{[0] =  msg.id})
end

if text:match('^[Ff][Ii][Ll][Tt][Ee][Rr] +(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local w = text:match('^[Ff][Ii][Ll][Tt][Ee][Rr] +(.*)$')
if redis:sismember('filters'..msg.chat_id,w) then
sendText(msg.chat_id, msg.id, '• عبارت مورد نظر از قبل فیلتر شده است !\n\n» عبارت : [ '..w..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• عبارت مورد نظر شما با موفقیت فیلتر گردید !\n\n» عبارت : [ '..w..' ]\n\n• Ch : '..channel..'', 'html')
redis:sadd('filters'..msg.chat_id,w)
end
end

if text:match('^[Rr][Ee][Mm][Ff][Ii][Ll][Tt][Ee][Rr] +(.*)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local w = text:match('^[Rr][Ee][Mm][Ff][Ii][Ll][Tt][Ee][Rr] +(.*)$')
if not redis:sismember('filters'..msg.chat_id,w) then
sendText(msg.chat_id, msg.id, '• عبارت مورد نظر فیلتر نشده است !\n\n» عبارت : [ '..w..' ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• عبارت مورد نظر شما با موفقیت رفع فیلتر گردید !\n\n» عبارت : [ '..w..' ]\n\n• Ch : '..channel..'', 'html')
redis:srem('filters'..msg.chat_id,w)
end
end

if text:match('^[Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('filters'..msg.chat_id)
local text = '• لیست عبارات فیلتر شده :\n\n'
for k,v in pairs(list) do
text = text..k.." - [ <i>"..v.."</i> ]\n"
end
if #list == 0 then
text = '• لیست عبارات فیلتر شده گروه خالی میباشد !\n\n» شما میتوانید با دستور\n<code>Filter</code> <i>text</i>\nعبارت مورد نظر خود را فیلتر کنید .\n\n• Ch : '..channel..''
end
sendText(msg.chat_id, msg.id, text, 'html')
end

if text:match('^[Cc][Ll][Ee][Aa][Nn] [Ff][Ii][Ll][Tt][Ee][Rr][Ll][Ii][Ss][Tt]$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local list = redis:smembers('filters'..msg.chat_id)
local num = redis:scard('filters'..msg.chat_id)
if #list == 0 then
sendText(msg.chat_id, msg.id, '• لیست عبارات فیلتر شده گروه خالی میباشد !\n\n» شما میتوانید با دستور\n`Filter` _text_\nعبارت مورد نظر خود را فیلتر کنید.\n\n• Ch : '..channel..'', 'md')
else
sendText(msg.chat_id, msg.id, '• عبارات فیلتر شده در گروه با موفقیت پاکسازی شدند !\n\n» تعداد عبارات فیلتر شده : [ <code>'..num..'</code> ]\n\n• Ch : '..channel..'', 'html')
redis:del('filters'..msg.chat_id)
end
end

if text:match('^[Pp][Ii][Nn]$') and Force(msg) then
if msg.reply_to_message_id == 0  then
sendText(msg.chat_id, msg.id, '• برای استفاده از این دستور لطفا بر روی پیام مد نظر کلیک کنید !', 'html')
else
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• پیام مورد نظر شما با موفقیت سنجاق گردید !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
Pin(msg.chat_id, msg.reply_to_message_id)
end
end

if text:match('^[Uu][Nn][Pp][Ii][Nn]$') and Force(msg) then
local usrname = redis:get('usrname'..msg.sender_user_id)
if usrname then
username = '@'..usrname..''
else
username = '<code>'..msg.sender_user_id..'</code> - <a href="tg://user?id='..msg.sender_user_id..'">» Click «</a>'
end
sendText(msg.chat_id, msg.id, '• پیام سنجاق شده با موفقیت از سنجاق خارج گردید !\n\n» شخص دستور دهنده : [ '..username..' ]\n\n• Ch : '..channel..'', 'html')
unpin(msg.chat_id)
end

if (text:match('^[Hh][Ee][Ll][Pp]$') or text:match("^help"..botusername.."$")) and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local f = io.open("help.txt", "rb")
local file = f:read("*all")
sendText(msg.chat_id, msg.id, file, 'html')
if f then
f:close()
end
end

end -- end mod


if is_vip(msg) then

if text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local id = text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$')
local function Whois(extra, result, success)
if result.first_name then
local user = 'Click!'
SendMetion(msg.chat_id,result.id, msg.id, user, 0, utf8.len(user))
else
sendText(msg.chat_id, msg.id, '• کاربر [ <code>'..id ..'</code> ] یافت نشد !', 'html')
end
end
getUser(id, Whois, nil)
end

if text:match('^[Ii][Dd] (.*)') and msg.content.entities and msg.content.entities[0] and msg.content.entities[0].type._ == "textEntityTypeMentionName" and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
id = msg.content.entities[0].type.user_id
sendText(msg.chat_id, msg.id, '• [ <code>'..id..'</code> ] •', 'html')
end

if text:match("^[Ii][Dd] @(.*)$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
function id_username(extra, result, success)
if result.id then
sendText(msg.chat_id, msg.id, '• [ <code>'..result.id..'</code> ] •', 'html')
else
sendText(msg.chat_id, msg.id, '• کاربری با یوزرنیم [ @'..text:match("^[Ii][Dd] @(.*)$") ..' ] وجود ندارد !', 'html')
end
end
searchPublicChat(text:match("^[Ii][Dd] @(.*)$"),id_username)
end

if text:match('^[Ii][Nn][Ff][Oo]$') and tonumber(msg.reply_to_message_id) > 0 and Force(msg) then
local offsett = 1
local function id_reply(extra, result, success)
local function GetProf(arg, data, success)
if not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
local gmsgs = redis:get('groupmsgs'..msg.chat_id..':') or 0
local msgs = redis:get('usermsgs'..msg.chat_id..':'..result.sender_user_id) or 0
if data.total_count then
data.total_count = data.total_count
else
data.total_count = 0
end
if is_sudo(result) then
sath = 'سازنده ربات'
elseif is_admin(result) then
sath= 'مدیر ربات'
elseif is_owner(result) then
sath= 'مالک گروه'
elseif is_mod(result) then
sath= 'مدیر گروه'
elseif is_vip(result) then
sath = 'کاربر ویژه'
else
sath = 'فرد عادی'
end
if result.forward_info then
sendText(msg.chat_id, msg.id, '• مشخصات دریافتی از پیام :\n\n» آیدی کاربری فوروارد : [ <code>'..result.forward_info.sender_user_id..'</code> ]\n» آیدی کاربری شخص : [ <code>'..result.sender_user_id..'</code> ]\n\n» آیدی پیام ریپلی شده : [ <code>'..msg.reply_to_message_id..'</code> ]\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• مشخصات دریافتی از کاربر :\n\n» آیدی کاربری شخص : [ <code>'..result.sender_user_id..'</code> ]\n» آیدی پیام ریپلی شده : [ <code>'..msg.reply_to_message_id..'</code> ]\n\n» تعداد اخطارهای دریافتی کاربر : [ <code>'..(redis:hget("warn"..msg.chat_id, result.sender_user_id) or 0)..'</code> ]\n» کاربران اضافه شده توسط کاربر : [ <code>'..(redis:get(msg.chat_id..'addmembers'..result.sender_user_id) or 0)..'</code> ]\n\n» سطح دسترسی کاربر : [ '..sath..' ]\n» مقام ثبت شده در ربات : [ '..(redis:get('ranks'..result.sender_user_id) or '------')..' ]\n\n» تعداد پیام های ارسالی کاربر : [ <code>'..(redis:get('usermsgs'..msg.chat_id..':'..result.sender_user_id) or 0)..'</code> ]\n» تعداد پروفایل های موجود کاربر : [ <code>'..data.total_count..'</code> ]\n\n• Ch : '..channel..'', 'html')
end
end
end
getUserProfilePhotos(result.sender_user_id, offsett-1, 200, GetProf)
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), id_reply)
end

if (text:match('^بگو (.*)') or text:match('^[Ee]cho (.*)')) and Force(msg) and tonumber(msg.reply_to_message_id) == 0 then
local txt = text:match('^بگو (.*)') or text:match('^[Ee]cho (.*)')
sendText(msg.chat_id, msg.id, txt, 'html')
end

if text:match('^بگو (.*)') and Force(msg) and tonumber(msg.reply_to_message_id) > 0 then
local txt = text:match('^بگو (.*)')
local function id_reply(extra, result, success)
local function Whois(arg, data, success)
if tonumber(result.sender_user_id) == tonumber(Mehdi) then
local name = okname(data.first_name)
sendText(msg.chat_id, msg.reply_to_message_id, 'بابایی ( ['..name..'](tg://user?id='..msg.sender_user_id..') ) به کیرم دست زد :(', 'md')
elseif tonumber(result.sender_user_id) == tonumber(ReacTance_id) then
local name = okname(data.first_name)
sendText(msg.chat_id, msg.reply_to_message_id, '['..name..'](tg://user?id='..msg.sender_user_id..')\nبه کیرم دست نزن :(', 'md')
elseif not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
deleteMessages(msg.chat_id,{[0] =  msg.id})
sendText(msg.chat_id, msg.reply_to_message_id, txt, 'html')
end
end
getUser(msg.sender_user_id, Whois, nil)
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), id_reply)
end
if text:match(('^بکنش$')) and Force(msg) and tonumber(msg.reply_to_message_id) > 0 then
local txt = text:match('^بکنش$')
local function id_reply(extra, result, success)
local function Whois(arg, data, success)
if tonumber(result.sender_user_id) == tonumber(Mehdi) then
local name = okname(data.first_name)
sendText(msg.chat_id, msg.reply_to_message_id, 'من بابامو نمیتونم بکنم ک :(', 'md')
elseif tonumber(result.sender_user_id) == tonumber(ReacTance_id) then
local name = okname(data.first_name)
sendText(msg.chat_id, msg.reply_to_message_id, 'خودمو نمیتونم بکنم ک :(', 'md')
elseif not result.sender_user_id then
sendText(msg.chat_id, msg.id, '• متاسفانه ربات های (Api) قادر به چک کردن پیام های یکدیگر نمیباشند !\n\n» لطفا از طریق یوزرنیم یا شناسه عددی ربات اقدام به انجام عملیات کنید .', 'html')
else
local p = {"کون تپلو","اینو بگام ۱۰۰سال جوون میشم 😂👑","سیاه هارو نمکنم ☺","بکنمش ینی؟","فاعاک چ کونی","تنگه چ حالی میده کردمش اوف","خوشت میاد بیب؟" ,"جون چ کونیه لامصب","لامصب چ کونیه","حیف شد سگ گایی گزاشتم کنار","با اینکه سگ گایی گزاشتم کنار باشه میکنمش","کون نیس لامصب شاه کونه"}
sendText(msg.chat_id, msg.reply_to_message_id,' '..p[math.random(#p)]..'', 'md')
end
end
getUser(msg.sender_user_id, Whois, nil)
end
getMessage(msg.chat_id, tonumber(msg.reply_to_message_id), id_reply)
end

end -- end vip


if not is_channel(msg) then

if text:match('^[Gg][Ee][Tt][Pp][Rr][Oo] (%d+)$') and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local offset = tonumber(text:match('^[Gg][Ee][Tt][Pp][Rr][Oo] (%d+)$'))
if offset > 200 then
sendText(msg.chat_id, msg.id, '• محدودیت ارسال عکس بر روی [ <code>200</code> ] عکس تنظیم شده است !\n\n» شما میباست کمتر از [ <code>200</code> ] عکس درخواست کنید .\n\n• Ch : '..channel..'', 'html')
elseif offset < 1 then
sendText(msg.chat_id, msg.id, '• کاربر گرامی درخواست شما امکان پذیر نیست !\n\n» برای دریافت عکس ها خود عددی بزرگ تر از `صفر` وارد کنید !\n\n• Ch : '..channel..'', 'md')
else
function GetPro(extra, result, success)
if result.photos[0] then
sendPhoto(msg.chat_id, msg.id, 0, 1, nil, result.photos[0].sizes[2].photo.persistent_id,'» تعداد پروفایل : [ '..offset..'/'..result.total_count..' ]\n» سایز عکس : [ '..result.photos[0].sizes[2].photo.size..' پیکسل ]\n• Ch : '..channel..'')
else
sendText(msg.chat_id, msg.id, '• کاربر گرامی درخواست شما امکان پذیر نیست !\n\n» عکس های موجود شما کمتر از [ <code>'..offset..'</code> ] عکس است.\n\n• Ch : '..channel..'', 'html')
end
end
getUserProfilePhotos(msg.sender_user_id, offset-1, 200, GetPro)
end
end

if (text:match('^[Bb][Oo][Tt]$') or text:match('^ربات$')) and tonumber(msg.reply_to_message_id) == 0 then
if redis:get('ranks'..msg.sender_user_id) then
local rank =  redis:get('ranks'..msg.sender_user_id)
local  k = {"جونم","جانم","چیه همش صدام میکنی","خستم کردی","بلههه"}
sendText(msg.chat_id, msg.id, ''..k[math.random(#k)]..' '..rank..'','html')
else
local p = {"جونم","جانم","بنال","چیه همش صدام میکنی","خستم کردی","بلههه","😕" ,"بگو","😐","بای","هن","هعی"}
sendText(msg.chat_id, msg.id, ''..p[math.random(#p)]..'', 'html')
end
end

if (text:match('^[Cc][Oo][Tt]$') or text:match('^چطور خودمو بکشم$')) and tonumber(msg.reply_to_message_id) == 0 then
if redis:get('ranks'..msg.sender_user_id) then
local rank =  redis:get('ranks'..msg.sender_user_id)
local  k = {"جق بزن آبکیرتو بخور میمیری","ازکیر خودتو دار بزن","برو زیر گاو کیرشو بکن تو دهنت بشینه روت بمیری","دستتو بکن تو کونت انقد بگو آی آی تا بمیری","یه چنگالو بردار دورش سیم برق بپیچ بکن توکونت برق بگیرتت بمیری"}
sendText(msg.chat_id, msg.id, ''..k[math.random(#k)]..' '..rank..'','html')
else
local p = {"میکننت میمیری","برو حموم زنونه اول میگانت بد میمیری","جق بزن آبکیرتو بخور میمیری","ی مار بنداز تو اتاق کنار خودت چنان میمیری حد نداره","یه چنگالو بردار دورش سیم برق بپیچ بکن توکونت برق بگیرتت بمیری","دستتو بکن تو کونت انقد بگو آی آی تا بمیری","برو زیر گاو کیرشو بکن تو دهنت بشینه روت بمیری","ازکیر خودتو دار بزن"}
sendText(msg.chat_id, msg.id, ''..p[math.random(#p)]..'', 'html')
end
end

if (text:match('^[Kk][Ii]Rr]$') or text:match('^کیرم چقدره$')) and tonumber(msg.reply_to_message_id) == 0 then
if redis:get('ranks'..msg.sender_user_id) then
local rank =  redis:get('ranks'..msg.sender_user_id)
local  k = {"ای قربونش برم","بخورش بگمت","فاعاک"," 😂❤","اینقدر کیر کیر نکن باو کیر نشده هنو شومبوله"}
sendText(msg.chat_id, msg.id, ''..k[math.random(#k)]..' '..rank..'','html')
else
local p = {"ب سانت نرسیده","شومبوله هنوز کیر نشده","اندازه هسته خرما","هعی کیر نی هنو"," سیک","اسمش کیر نی","22سانت" ," سانت","نداری هنو","اندازه دوسسسسسسس داری؟ بیام کیرمو نشونت بدم اندازرو بفهمی","اندازه قوطی نوشابه","5سانت"}
sendText(msg.chat_id, msg.id, ''..p[math.random(#p)]..'', 'html')
end
end

if (text:match('^[Hh][Oo][Tt]$') or text:match('^کصم چطوریه$')) and tonumber(msg.reply_to_message_id) == 0 then
if redis:get('ranks'..msg.sender_user_id) then
local rank =  redis:get('ranks'..msg.sender_user_id)
local  k = {"نرختو بگو باو","ای قربون اوک کصت","فاک جونز","کصمشنگ","کص قشنگ"}
sendText(msg.chat_id, msg.id, ''..k[math.random(#k)]..' '..rank..'','html')
else
local p = {"قشنگ","پاره","سیاه و زشت","حلقوی","سیاه","تنگ","گشاد" ,"کلوچه ای","سفید","تپل","هلویی","استخونی"}
sendText(msg.chat_id, msg.id, ''..p[math.random(#p)]..'', 'html')
end
end

if (text:match('^[Bb][Yy][Ee]$') or text:match('^[Bb][Yy]$') or text:match('^بای$') or text:match('^باعی$') or text:match('^خدافظی$') or text:match('^خدافظ$') or text:match('^باي$')) and tonumber(msg.reply_to_message_id) == 0 then
if redis:get('ranks'..msg.sender_user_id) then
local rank =  redis:get('ranks'..msg.sender_user_id)
local  k = {"باعی","بوس","فعلا","خدافظ","بای"}
sendText(msg.chat_id, msg.id, ''..k[math.random(#k)]..' '..rank..'','md')
else
local p = {"باعی","فعلا","خدافظ","بای","خدافظی"}
sendText(msg.chat_id, msg.id, ''..p[math.random(#p)]..'', 'html')
end
end

if (text:match('^[Mm][Ee]$') or text:match('^me'..botusername..'$')) and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local offset = 1
function UserName(extra, full, success)
function Name(extra, result, success)
function GetPros(extra, mehdi, success)
local addlist = redis:get('addlistbot'..msg.sender_user_id..':') or 0
local rank =  redis:get('ranks'..msg.sender_user_id) or '------'
local gmsgs = redis:get('groupmsgs'..msg.chat_id..':') or 0
local nwarn = redis:hget("warn"..msg.chat_id,msg.sender_user_id) or 0
local add = redis:get(msg.chat_id..'addmembers'..msg.sender_user_id) or 0
local msgs = redis:get('usermsgs'..msg.chat_id..':'..msg.sender_user_id) or 0
if full.is_blocked then
resultblock = 'بله'
else
resultblock = 'خیر'
end
if full.can_be_called then
resultcall = 'مجاز'
else
resultcall = 'غیرمجاز'
end
if full.has_private_calls then
resultcallmode = 'خصوصی'
else
resultcallmode = 'عمومی'
end
if result.phone_number ~= '' then
result.phone_number = ''..result.phone_number..''
else
result.phone_number = '------'
end
if result.status.expires  then
onoff  = ''..(os.date("%X", result.status.expires))..''
else
onoff  = 'آخرین بازدید اخیرا'
end
if mehdi.total_count then
mehdi.total_count = mehdi.total_count
else
mehdi.total_count = 0
end
if mehdi.photos[0] then
Prosize = ''..mehdi.photos[0].sizes[2].photo.size..''
else
Prosize = '------'
end
if result.username ~= '' then
username = '@'..result.username
else
username = '------'
end
if full.about ~= '' then
about = full.about
else
about = '------'
end
local first_name = '> Click <'
if is_sudo(msg) then
t = 'سازنده ربات'
elseif is_admin(msg) then
t = 'مدیر ربات'
elseif is_owner(msg) then
t = 'مالک گروه'
elseif is_mod(msg) then
t = 'مدیر گروه'
elseif is_vip(msg) then
t = 'کاربر ویژه'
else
t = 'فرد عادی'
end
SendMetion(msg.chat_id,msg.sender_user_id, msg.id, '• بخشی از اطلاعات کاربری شما :\n\n» نام کاربری شما : [ '..first_name..' ]\n» آیدی کاربری شما : [ '..msg.sender_user_id..' ]\n\n» یوزرنیم کاربری شما : [ '..username..' ]\n» شماره موبایل شما : [ '..result.phone_number..' ]\n\n» تعداد پیام های شما : [ '..msgs..' ]\n» تعداد پیام های گروه : [ '..gmsgs..' ]\n\n» تعداد پروفایل های شما : [ '..mehdi.total_count..' ]\n» سایز آخرین پروفایل شما : [ '..Prosize..' ]\n\n» مقام کاربری شما : [ '..rank..' ]\n» سطح دسترسی شما : [ '..t..' ]\n\n» تعداد گروه های مشترک : [ '..full.common_chat_count..' ]\n» تعداد گروهای نصب شده توسط شما : [ '..addlist..' ]\n\n» تعداد اخطار های دریافتی شما : [ '..nwarn ..' ]\n» تعداد افراد اضافه شده توسط شما : [ '..add..' ]\n\n» تماس با شما از طریق تلگرام : [ '..resultcall..' ]\n» نوع تماس با شما از طریق تلگرام : [ '..resultcallmode..' ]\n\n» بیوگرافی :\n[ '..about..' ]\n\n• Ch : '..channel..'', 53, string.len(msg.sender_user_id))
end
getUserProfilePhotos(msg.sender_user_id, offset-1, 200, GetPros, nil)
end
getUser(msg.sender_user_id, Name, nil)
end
getUserFull(msg.sender_user_id, UserName, nil)
end

if (text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^link"..botusername.."$")) and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local link = redis:get('link'..msg.chat_id)
local GroupName = redis:get('groupName'..msg.chat_id)
local gpname = okname(GroupName)
if link then
sendText(msg.chat_id, msg.id, '[» '..(gpname or 'Error Saving')..' «]('..link..')', 'md')
else
sendText(msg.chat_id, msg.id, '• در حال حاضر لینکی برای گروه ثبت نشده است !\n\n» برای ثبت لینک از دستور \n`Setlink` _link_\nاستفاده کنید .\n\n• Ch : '..channel..'', 'md')
end
end

if (text:match("^[Rr][Uu][Ll][Ee][Ss]$") or text:match("^rules"..botusername.."$")) and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local rules = redis:get('rules'..msg.chat_id)
if rules then
sendText(msg.chat_id, msg.id, '• قوانین ثبت شده برای گروه عبارتند از :\n\n» { '..rules..' }\n\n• Ch : '..channel..'', 'html')
else
sendText(msg.chat_id, msg.id, '• در حال حاضر قانونی برای گروه ثبت نشده است !\n\n» برای ثبت قوانین از دستور \n`Setrules` _text_\nاستفاده کنید .\n\n• Ch : '..channel..'', 'md')
end
end

if (text:match('^[Ii][Dd]$') or text:match('^آیدی$') or text:match('^ایدی$')) and tonumber(msg.reply_to_message_id) == 0 then
local function profile(extra, result, success)
local msgs = redis:get('usermsgs'..msg.chat_id..':'..msg.sender_user_id) or 0
if result.photos[0] then
sendPhoto(msg.chat_id, msg.id, 0, 1, nil, result.photos[0].sizes[2].photo.persistent_id,'» شناسه شما : [ '..msg.sender_user_id..' ]\n» تعداد پیام های شما : [ '..msgs..' ]\n» شناسه گروه : [ '..msg.chat_id..' ]\n• Ch : '..channel..'')
else
sendPhoto(msg.chat_id, msg.id, 0, 1, nil, 'AgADAgAD_qgxGwFgUUsnZeVsYrkfhwzNrA4ABI5J5HlLmu7FKjsBAAEC','» شناسه شما : [ '..msg.sender_user_id..' ]\n» تعداد پیام های شما : [ '..msgs..' ]\n» شناسه گروه : [ '..msg.chat_id..' ]\n• Ch : '..channel..'', dl_cb, nil)
end
end
getUserProfilePhotos(msg.sender_user_id, 0, 8585, profile, nil)
end

if text:match("^[Dd][Aa][Tt][Ee]$") and tonumber(msg.reply_to_message_id) == 0 and Force(msg) then
local url , res = http.request('http://probot.000webhostapp.com/api/time.php/')
if res ~= 200 then return sendText(msg.chat_id, msg.id, '• خطا در متصل شدن به وب سرویس !', 'html') end
local jdat = json:decode(url)
if jdat.L == "0" then
jdat_L = 'خیر'
elseif jdat.L == "1" then
jdat_L = 'بله'
end
local text = '• ارائه شده توسط وب سرویس پروبات !\n\n» ساعت : <code>'..jdat.Stime..'</code>\n\n» تاریخ : <code>'..jdat.FAdate..'</code>\n\n» تعداد روز های ماه جاری : <code>'..jdat.t..'</code>\n\n» عدد روز در هفته : <code>'..jdat.w..'</code>\n\n» شماره ی این هفته در سال : <code>'..jdat.W..'</code>\n\n» نام باستانی ماه : <code>'..jdat.p..'</code>\n\n» شماره ی ماه از سال : <code>'..jdat.n..'</code>\n\n» نام فصل : <code>'..jdat.f..'</code>\n\n» شماره ی فصل از سال : <code>'..jdat.b..'</code>\n\n» تعداد روز های گذشته از سال : <code>'..jdat.z..'</code>\n\n» در صد گذشته از سال : <code>'..jdat.K..'</code>\n\n» تعداد روز های باقیمانده از سال : <code>'..jdat.Q..'</code>\n\n» در صد باقیمانده از سال : <code>'..jdat.k..'</code>\n\n» نام حیوانی سال : <code>'..jdat.q..'</code>\n\n» شماره ی قرن هجری شمسی : <code>'..jdat.C..'</code>\n\n» سال کبیسه : <code>'..jdat_L..'</code>\n\n» منطقه ی زمانی تنظیم شده : <code>'..jdat.e..'</code>\n\n» اختلاف ساعت جهانی : <code>'..jdat.P..'</code>\n\n» اختلاف ساعت جهانی به ثانیه : <code>'..jdat.A..'</code>\n\n• Ch : '..channel..''
sendText(msg.chat_id, msg.id, text, 'html')
end

end -- end not channel

end -- end checkdone

end -- end text

end -- end DarkLiNuX


function tdbot_update_callback(data)
if (data._ == "updateNewMessage") or (data._ == "updateNewChannelMessage") then
DarkLiNuX(data.message, data)
elseif (data._== "updateMessageEdited") then
local function edited_cb(extra, result, success)
DarkLiNuX(result, data)
end
assert (tdbot_function ({_ = "getMessage", chat_id = data.chat_id, message_id = data.message_id }, edited_cb, nil))
assert (tdbot_function ({_ = "getChats", offset_order = "9223372036854775807", offset_chat_id = 0, limit = 20 }, dl_cb, nil))
end
end

-- Armin Alijani
-- The End
