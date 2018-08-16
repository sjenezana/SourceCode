#/usr/bin/env python
#coding=utf8
 
import http.client
import hashlib 
import random
import openpyxl
import json

print('translate begin...')



def translateBaidu(content):

    appid = '20180816000194959'
    secretKey = 'lWzwUiWmhRORknf68FCT'
    httpClient = None
    myurl = '/api/trans/vip/translate'
    q = content
    fromLang = 'en' # 源语言
    toLang = 'zh'   # 翻译后的语言
    salt = random.randint(32768, 65536)
    sign = str(appid) + q + str(salt) + secretKey
 
    sign = hashlib.md5(sign.encode("utf-8")).hexdigest()
    myurl = myurl + '?appid=' + appid + '&q=' + urllib.parse.quote(q) + '&from=' + fromLang + '&to=' + toLang + '&salt=' + str(salt) + '&sign=' + sign
 
    try:
        httpClient = http.client.HTTPConnection('api.fanyi.baidu.com')
        httpClient.request('GET', myurl)
    
        #response是HTTPResponse对象
        response = httpClient.getresponse()  
        jsonResponse = response.read().decode("utf-8")# 获得返回的结果，结果为json格式
        print(jsonResponse)
        js = json.loads(jsonResponse)  # 将json格式的结果转换字典结构
        dst = str(js["trans_result"][0]["dst"])  # 取得翻译后的文本结果 
    except Exception as e:
        print(e)
    finally:
        if httpClient:
            httpClient.close()


wb = openpyxl.load_workbook('c:\_Work\chinesetranslation.xlsx')
sheet = wb.get_sheet_by_name('Sheet1') 
fromLang = 'en'
toLang = 'zh'

for i in range (121,125,1 ):
    print(sheet.cell(row=i, column=3).value)
    print(i, translateBaidu(sheet.cell(row=i, column=3).value))