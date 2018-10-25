# -*- coding: utf-8 -*-
import telebot
import logging
import json
import os
from telebot import util
import re
from random import randint
import random
import requests as req
import requests
import commands
import urllib2
import urllib
import telebot
import ConfigParser
import redis as r
import redis as redis
session = requests.session()
from telebot import types
import sys
reload(sys)
sys.setdefaultencoding("utf-8")
token = '626823162:AAEf6crvLGqfhGxD7740RXRycpQkUfbqCRY' #Token
bot = telebot.TeleBot(token)
database = redis.StrictRedis(host='localhost', port=6379, db=1, decode_responses=True)
sudos = [640960815] #Sudo IDs
channels = 640960815 #Channel ID
db = "https://api.telegram.org/bot{}/getMe?".format(token)
res = urllib.urlopen(db)
res_body = res.read()
parsed_json = json.loads(res_body.decode("utf-8"))
botid = parsed_json['result']['id']
botuser = parsed_json['result']['username']
bhash = "blocked:users:{}".format(botuser)

bot.send_message(channels,">DELTA Robot Has Been Running ...!".format())

def delmessage(token, chat_id, message_id):
	openurl = session.request('get', "https://api.telegram.org/bot{}/deletemessage?chat_id={}&message_id={}".format(token, chat_id, message_id), params=None, files=None, timeout=(3.5, 9999))

def info(gpslock3):

	mediainfo = types.InlineKeyboardMarkup()

	mediainfo.add(types.InlineKeyboardButton('Armin Alijani', url='https://telegram.me/ArminNy'), types.InlineKeyboardButton('Payam Resan', url='https://telegram.me/ArminNybot'))

	mediainfo.add(types.InlineKeyboardButton('Channel', url='https://telegram.me/DELTATM'))

	mediainfo.add(types.InlineKeyboardButton('بازگشت', callback_data='menue'))

	return mediainfo

def setting1(gpslock1):

	mediasetting1 = types.InlineKeyboardMarkup()
	
	mediasetting1.add(types.InlineKeyboardButton('تنظیمات', callback_data='backpage'))

	mediasetting1.add(types.InlineKeyboardButton('درباره ما', callback_data='infome'))

	mediasetting1.add(types.InlineKeyboardButton('کانال ما', url='https://telegram.me/DELTATM'))

	mediasetting1.add(types.InlineKeyboardButton('بستن', callback_data='close'))

	return mediasetting1

def setting(gpslock):

	mediasetting = types.InlineKeyboardMarkup()

	if database.get('link'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unlink'), types.InlineKeyboardButton('قفل لینک', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='link'), types.InlineKeyboardButton('قفل لینک', callback_data='eshteba'))

	if database.get('forward'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unforward'), types.InlineKeyboardButton('قفل فوروارد', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='forward'), types.InlineKeyboardButton('قفل فوروارد', callback_data='eshteba'))

	if database.get('username'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unuser'), types.InlineKeyboardButton('قفل یوزرنیم', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='username'), types.InlineKeyboardButton('قفل یوزرنیم', callback_data='eshteba'))

	if database.get('hashtag'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='untag'), types.InlineKeyboardButton('قفل هشتگ', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='tag'), types.InlineKeyboardButton('قفل هشتگ', callback_data='eshteba'))

	if database.get('persian'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unpersian'), types.InlineKeyboardButton('قفل فارسی', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='persian'), types.InlineKeyboardButton('قفل فارسی', callback_data='eshteba'))

	if database.get('english'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unenglish'), types.InlineKeyboardButton('قفل انگلیسی', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='english'), types.InlineKeyboardButton('قفل انگلیسی', callback_data='eshteba'))

	if database.get('badword'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unfosh'), types.InlineKeyboardButton('قفل فحش', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='fosh'), types.InlineKeyboardButton('قفل فحش', callback_data='eshteba'))

	if database.get('bot'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unbot'), types.InlineKeyboardButton('قفل ربات', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='bot'), types.InlineKeyboardButton('قفل ربات', callback_data='eshteba'))

	if database.get('join'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='unjoin'), types.InlineKeyboardButton('قفل ورودی', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='join'), types.InlineKeyboardButton('قفل ورودی', callback_data='eshteba'))

	if database.get('cmd'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='uncmd'), types.InlineKeyboardButton('قفل دستورات', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='cmd'), types.InlineKeyboardButton('قفل دستورات', callback_data='eshteba'))

	if database.get('tgservice'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='untgservice'), types.InlineKeyboardButton('قفل پیام سرویسی', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='tgservice'), types.InlineKeyboardButton('قفل پیام سرویسی', callback_data='eshteba'))

	if database.get('text'+str(gpslock)):
		mediasetting.add(types.InlineKeyboardButton('فعال', callback_data='untext'), types.InlineKeyboardButton('قفل متن', callback_data='eshteba'))
	else:
		mediasetting.add(types.InlineKeyboardButton('غیرفعال', callback_data='text'), types.InlineKeyboardButton('قفل متن', callback_data='eshteba'))

	mediasetting.add(types.InlineKeyboardButton('بعدی', callback_data='next'))

	mediasetting.add(types.InlineKeyboardButton('قبلی', callback_data='menue'))

	return mediasetting

def setting2(gpslock2):

	mediasetting2 = types.InlineKeyboardMarkup()

	if database.get('gif'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='ungif'), types.InlineKeyboardButton('قفل گیف', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='gif'), types.InlineKeyboardButton('قفل گیف', callback_data='eshteba'))

	if database.get('contact'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='uncontact'), types.InlineKeyboardButton('قفل مخاطب', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='contact'), types.InlineKeyboardButton('قفل مخاطب', callback_data='eshteba'))

	if database.get('photo'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unphoto'), types.InlineKeyboardButton('قفل عکس', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='photo'), types.InlineKeyboardButton('قفل عکس', callback_data='eshteba'))

	if database.get('video'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unvideo'), types.InlineKeyboardButton('قفل فیلم', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='video'), types.InlineKeyboardButton('قفل فیلم', callback_data='eshteba'))

	if database.get('voice'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unvoice'), types.InlineKeyboardButton('قفل صدا', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='voice'), types.InlineKeyboardButton('قفل صدا', callback_data='eshteba'))

	if database.get('music'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unmusic'), types.InlineKeyboardButton('قفل آهنگ', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='music'), types.InlineKeyboardButton('قفل آهنگ', callback_data='eshteba'))

	if database.get('game'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='ungame'), types.InlineKeyboardButton('قفل بازی', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='game'), types.InlineKeyboardButton('قفل بازی', callback_data='eshteba'))

	if database.get('sticker'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unsticker'), types.InlineKeyboardButton('قفل استیکر', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='sticker'), types.InlineKeyboardButton('قفل استیکر', callback_data='eshteba'))

	if database.get('document'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unfile'), types.InlineKeyboardButton('قفل فایل', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='file'), types.InlineKeyboardButton('قفل فایل', callback_data='eshteba'))

	if database.get('inline'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='uninline'), types.InlineKeyboardButton('قفل اینلاین', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='inline'), types.InlineKeyboardButton('قفل اینلاین', callback_data='eshteba'))

	if database.get('videonote'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unnote'), types.InlineKeyboardButton('قفل فیلم سلفی', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='note'), types.InlineKeyboardButton('قفل فیلم سلفی', callback_data='eshteba'))

	if database.get('location'+str(gpslock2)):
		mediasetting2.add(types.InlineKeyboardButton('فعال', callback_data='unloc'), types.InlineKeyboardButton('قفل موقعیت مکانی', callback_data='eshteba'))
	else:
		mediasetting2.add(types.InlineKeyboardButton('غیرفعال', callback_data='loc'), types.InlineKeyboardButton('قفل موقعیت مکانی', callback_data='eshteba'))

	mediasetting2.add(types.InlineKeyboardButton('قبلی', callback_data='backpage'))

	mediasetting2.add(types.InlineKeyboardButton('صفحه اصلی', callback_data='menue'))

	return mediasetting2

@bot.callback_query_handler(func=lambda call: True)
def callback_inline(call):

	if call.from_user.id in sudos or database.sismember("admins", call.from_user.id) or database.sismember("owners"+str(call.message.chat.id), call.from_user.id) or database.sismember("mods"+str(call.message.chat.id), call.from_user.id):
		gplink = call.message.chat.id
		
		if call.data.startswith("unlink"):
			database.delete('link'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل لینک غيرفعال شد !")

		if call.data.startswith("link"):
			database.set('link'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل لینک فعال شد !")

		if call.data.startswith("unforward"):
			database.delete('forward'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فوروارد غيرفعال شد !")

		if call.data.startswith("forward"):
			database.set('forward'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فوروارد فعال شد !")

		if call.data.startswith("unuser"):
			database.delete('username'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل یوزرنیم غيرفعال شد !")

		if call.data.startswith("username"):
			database.set('username'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل یوزرنیم فعال شد !")

		if call.data.startswith("untag"):
			database.delete('hashtag'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل هشتگ غیرفعال شد !")

		if call.data.startswith("tag"):
			database.set('hashtag'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل هشتگ فعال شد !")

		if call.data.startswith("unpersian"):
			database.delete('persian'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فارسی غیرفعال شد !")

		if call.data.startswith("persian"):
			database.set('persian'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فارسی فعال شد !")

		if call.data.startswith("unenglish"):
			database.delete('english'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل انگلیسی غیرفعال شد !")

		if call.data.startswith("english"):
			database.set('english'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل انگلیسی فعال شد !")

		if call.data.startswith("unfosh"):
			database.delete('badword'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فحش غیرفعال شد !")

		if call.data.startswith("fosh"):
			database.set('badword'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فحش فعال شد !")

		if call.data.startswith("unbot"):
			database.delete('bot'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل ربات غیرفعال شد !")

		if call.data.startswith("bot"):
			database.set('bot'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل ربات فعال شد !")

		if call.data.startswith("unjoin"):
			database.delete('join'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل ورودی غیرفعال شد !")

		if call.data.startswith("join"):
			database.set('join'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل ورودی فعال شد !")

		if call.data.startswith("uncmd"):
			database.delete('cmd'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل دستورات غیرفعال شد !")

		if call.data.startswith("cmd"):
			database.set('cmd'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل دستورات فعال شد !")

		if call.data.startswith("untgservice"):
			database.delete('tgservice'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل پیام سرویسی غیرفعال شد !")

		if call.data.startswith("tgservice"):
			database.set('tgservice'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل پیام سرویسی فعال شد !")

		if call.data.startswith("untext"):
			database.delete('text'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل متن غیرفعال شد !")

		if call.data.startswith("text"):
			database.set('text'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل متن فعال شد !")

		if call.data.startswith("ungif"):
			database.delete('gif'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل گیف غیرفعال شد !")

		if call.data.startswith("gif"):
			database.set('gif'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل گیف فعال شد !")

		if call.data.startswith("uncontact"):
			database.delete('contact'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل مخاطب غیرفعال شد !")

		if call.data.startswith("contact"):
			database.set('contact'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل مخاطب فعال شد !")

		if call.data.startswith("unphoto"):
			database.delete('photo'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل عکس غیرفعال شد !")

		if call.data.startswith("photo"):
			database.set('photo'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل عکس فعال شد !")

		if call.data.startswith("unvideo"):
			database.delete('video'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فیلم غیرفعال شد !")

		if call.data.startswith("video"):
			database.set('video'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فیلم فعال شد !")

		if call.data.startswith("unvoice"):
			database.delete('voice'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل صدا غیرفعال شد !")

		if call.data.startswith("voice"):
			database.set('voice'+str(gplink), True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل صدا فعال شد !")

		if call.data.startswith("unmusic"):
			database.delete('music'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل آهنگ غیرفعال شد !")

		if call.data.startswith("music"):
			database.set('music'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل آهنگ فعال شد !")

		if call.data.startswith("ungame"):
			database.delete('game'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل بازی غیرفعال شد !")

		if call.data.startswith("game"):
			database.set('game'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل بازی فعال شد !")

		if call.data.startswith("unsticker"):
			database.delete('sticker'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل استیکر غیرفعال شد !")

		if call.data.startswith("sticker"):
			database.set('sticker'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل استیکر فعال شد !")

		if call.data.startswith("unfile"):
			database.delete('document'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فایل غیرفعال شد !")

		if call.data.startswith("file"):
			database.set('document'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فایل فعال شد !")

		if call.data.startswith("uninline"):
			database.delete('inline'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل اینلاین غیرفعال شد !")

		if call.data.startswith("inline"):
			database.set('inline'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل اینلاین فعال شد !")

		if call.data.startswith("unnote"):
			database.delete('videonote'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فیلم سلفی غیرفعال شد !")

		if call.data.startswith("note"):
			database.set('videonote'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل فیلم سلفی فعال شد !")

		if call.data.startswith("unloc"):
			database.delete('location'+str(gplink))
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل موقعیت مکانی غیرفعال شد !")

		if call.data.startswith("loc"):
			database.set('location'+str(gplink),True)
			bot.edit_message_reply_markup(chat_id=call.message.chat.id, message_id=call.message.message_id, reply_markup=setting2(gplink))
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="قفل موقعیت مکانی فعال شد !")

		if call.data.startswith("kick"):
			user_id = call.data.replace("kick","")
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text="• درخواست انجام شد !\n\n» کاربر ( [{}](tg://user?id={}) ) اخراج شد .".format(user_id, user_id), parse_mode="markdown")
			bot.kick_chat_member(call.message.chat.id, user_id)

		if call.data == "eshteba":
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="داداچ داری اشتباه میزنی 😹")

		if call.data == "online":
			bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="PONG")

		if call.data == "close":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='پنل مدیریتی بسته شد !')

		if call.data == "infome":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='با سلام 😺\n\nشما هم اکنون از پلن ربات کاملا رایگان , پرسرعت و پرقدرت دلتا استفاده میکنید !\n\nاین ربات توسط تیم دلتا که اعضای تیم ویزلی آن را تشکیل میدهند پایه گذاری و طراحی شده و قابلیت این را دارد که گروه شمارا بدون هیچ هزینه ای مدیریت کند !\n\nزبان برنامه نویسی این ربات ترکیبی از پایتون و لوا میباشد که بسیار سبک و پیشرفته است و حداقل پتانسیل مدیریت هزار گروه تلگرامی را دارد !\n\nشما میتوانید برای اطلاعات بیشتر و یا همکاری با ما با آیدی های زیر در ارتباط باشید 👾', reply_markup=info(gplink))

		if call.data == "next":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='• تنظیمات گروه مدیریتی به صورت زیر میباشد :\n\n» شما میتوانید با استفاده از این پنل تنظیمات گروه خود را تغییر دهید !\n\n• Page 2', reply_markup=setting2(gplink))

		if call.data == "menue":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='» به پنل مدیریتی ربات کاملا رایگان دلتا خوش آمدید !\n\n• لطفا یکی از گزینه های زیر را انتخاب کنید .', reply_markup=setting1(gplink))

		if call.data == "backpage":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='• تنظیمات گروه مدیریتی به صورت زیر میباشد :\n\n» شما میتوانید با استفاده از این پنل تنظیمات گروه خود را تغییر دهید !\n\n• Page 1', reply_markup=setting(gplink))

		if call.data == "notkicksender":
			bot.edit_message_text(chat_id=call.message.chat.id, message_id=call.message.message_id, text='• درخواست انجام شد !\n\n» پیام اخراج فرد بسته شد .')

	else:
		bot.answer_callback_query(callback_query_id=call.id, show_alert=False, text="شما دسترسی انجام این کار را ندارید !")

@bot.message_handler(content_types=['text'])
def locks(msg):

	if not database.sismember('gbaned', msg.from_user.id):
		
		if msg.text == "panel" or msg.text == "Panel" or msg.text == "/panel" or msg.text == "/panel@D_AntiSpam_bot":
			if database.sismember('donegp', msg.chat.id):
				if msg.from_user.id in sudos or database.sismember("admins", msg.from_user.id) or database.sismember("owners"+str(msg.chat.id), msg.from_user.id) or database.sismember("mods"+str(msg.chat.id), msg.from_user.id):
					bot.reply_to(msg, "» به پنل مدیریتی ربات کاملا رایگان دلتا خوش آمدید !\n\n• لطفا یکی از گزینه های زیر را انتخاب کنید .".format(), reply_markup=setting1(msg.chat.id))

		
		if msg.text == "ping" or msg.text == "Ping" or msg.text == "/ping" or msg.text == "/Ping" or msg.text == "PinG" or msg.text == "!ping":
			if database.sismember('donegp', msg.chat.id):
				markup2 = types.InlineKeyboardMarkup()
				a = types.InlineKeyboardButton("» PING «", callback_data='online')
				markup2.add(a)
				bot.reply_to(msg, "• D Onlined !".format(), reply_markup = markup2)

		if msg.text.lower() == "stats" or msg.text.lower() == "!stats" or msg.text.lower() == "/stats":
                  if database.sismember('donegp', msg.chat.id):
                        if msg.from_user.id in sudos or database.sismember("admins", msg.from_user.id):
                              ssgps = database.scard("donegp") or 0
                              sgps = database.scard("sgps") or 0
                              gps = database.scard("gps") or 0
                              users = database.scard("users") or 0
                              allmsgs = database.get("allmsg") or 0
                              markup = types.InlineKeyboardMarkup()
                              a = types.InlineKeyboardButton('» Installed Sgps : {} «'.format(ssgps), callback_data='mehdichch')
                              b = types.InlineKeyboardButton('» SuperGroups : {} «'.format(sgps), callback_data='mehdichch')
                              c = types.InlineKeyboardButton('» Groups : {} «'.format(gps), callback_data='mehdichch')
                              d = types.InlineKeyboardButton('» Users : {} «'.format(users), callback_data='mehdichch')
                              e = types.InlineKeyboardButton('» Total Msgs : {} «'.format(allmsgs), callback_data='mehdichch')
                              f = types.InlineKeyboardButton('» DELTATM «'.format(), url='https://t.me/DELTATM')
                              markup.add(a)
                              markup.add(b)
                              markup.add(c)
                              markup.add(d)
                              markup.add(e)
                              markup.add(f)
                              bot.reply_to(msg, "• DELTATM Api AntiSpam Robot Stats :\n‌ ‌".format(), reply_markup = markup)


	if msg.chat.type == "private":
		
		if not database.sismember('gbaned', msg.from_user.id):

			if msg.text == "/start" or msg.text == "start" or msg.text == "Start" or msg.text == "start@L1TDBOT":
    				bot.reply_to(msg, "• با سلام 🌹\n\n• از اینکه ربات کاملا رایگان دلتا را انتخاب کردید متشکریم ❤️\n\n• ما افتخار این را داریم که گروه شمارو بدون هیچ هزینه ای و با قدرت , سرعت و امکانات بالا اداره کنیم ✌️\n\n• اگر مایل به استفاده از ربات ما میباشید مراحل زیر را به ترتیب انجام دهید :\n\n- مرحله ی اول :\nابتدا ربات را به گروه خود اضافه کنید ، برای این کار به قسمت اضافه کردن عضو گروه مراجعه کنید و در قسمت جستجو آیدی ربات یعنی\n( @D_AntiSpam_bot )\nرا وارد کنید و سپس ربات را به گروه اضافه کنید .\n\n- مرحله ی دوم :\nاکنون پس از اضافه کردن ربات به گروه خود میبایست ربات را در گروه ادمین کنید تا فعالیت خود را به طور کامل انجام دهد .\n• توجه داشته باشید در صورت ادمین شدن ربات درگروه به مراحل بعد مراجعه کنید !\n\n- مرحله ی سوم :\nپس از ادمین کردن ربات از دستور\n/Start\nبرای فعال سازی و نصب ربات در گروه خود استفاده کنید .\n\n- نکته :\nشما میتوانید با استفاده از دستور\n/help\nبا دستورات ربات آشنا شوید و ربات را مدیریت کنید !\n\n• Ch : @DELTATM".format())

@bot.message_handler(content_types=['new_chat_members'])
def welcome(msg):

	if database.get("bot"+str(msg.chat.id)):
            if not msg.new_chat_member.id == botid:
	      	if msg.from_user.id in sudos or database.sismember("admins", msg.from_user.id) or database.sismember("owners"+str(msg.chat.id), msg.from_user.id) or database.sismember("mods"+str(msg.chat.id) , msg.from_user.id) or database.sismember("vips"+str(msg.chat.id), msg.from_user.id):
		      	print("Error Admin!")
	      	else:
		      	if msg.new_chat_member.username and msg.new_chat_member.username.lower().endswith("bot"):
                              markup2 = types.InlineKeyboardMarkup()
                              a = types.InlineKeyboardButton("بله",callback_data = "kick{}".format(msg.from_user.id))
                              b = types.InlineKeyboardButton("خیر",callback_data='notkicksender')
                              markup2.add(b, a)
                              text = "• ربات ( [{}](tg://user?id={}) ) اخراج شد !\n\n» آیا مایل به اخراج فرد دعوت کننده ربات میباشید !؟\n‌ ‌".format(msg.new_chat_member.id, msg.new_chat_member.id)
                              bot.send_message(msg.chat.id, text, parse_mode="markdown", reply_markup = markup2)
                              bot.kick_chat_member(msg.chat.id, msg.new_chat_member.id)

bot.polling(True)
