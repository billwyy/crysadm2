__author__ = 'powergx'
import requests
import json
import time
from crysadm_helper import r_session
from requests.adapters import HTTPAdapter

# Ѹ��API�ӿ�
appversion = '3.1.7'
server_address = 'http://1-api-red.xunlei.com'
agent_header = {'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11"}

# �ύѸ�����ӣ�������Ϣ
def api_post(url, data, cookies, headers=agent_header, timeout=60):
    url = server_address + url
    try:
        with requests.Session() as s:
            s.mount('http://', HTTPAdapter(max_retries=5))
            r = s.post(url=url, data=data, headers=headers, cookies=cookies, timeout=timeout)
    except requests.exceptions.RequestException as e:
        return __handle_exception(e=e)

    if r.status_code != 200:
        return __handle_exception(rd=r.reason)

    return json.loads(r.text)

# ������������
def exec_draw_cash(cookies, limits=None):
    r = get_can_drawcash(cookies)
    if r.get('r') != 0:
        return r

    if r.get('is_tm') == 0:
        return dict(r=0, rd=r.get('tm_tip'))

    r = get_balance_info(cookies)
    if r.get('r') != 0:
        return r

    wc_pkg = r.get('wc_pkg')

    if limits is not None and wc_pkg < limits: 
        return dict(r=1, rd='�ʻ������������ֵ%sԪ' % limits)

    if wc_pkg > 200:
        wc_pkg = 200

    r = draw_cash(cookies, wc_pkg)
    if r.get('r') != 0:
        return r

    return r

# ��ȡ������Ϣ
def get_can_drawcash(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='1', appversion=appversion)
    return api_post(url='/?r=usr/drawcashInfo', data=body, cookies=cookies)

# ����������
def get_balance_info(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='2', appversion=appversion)
    return api_post(url='/?r=usr/asset', data=body, cookies=cookies)

# �ύ��������
def draw_cash(cookies, money):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='3', m=str(money))
    return api_post(url='?r=usr/drawpkg', data=body, cookies=cookies)

# ��ȡMINE��Ϣ
def get_mine_info(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='4', appversion=appversion)
    return api_post(url='/?r=mine/info', data=body, cookies=cookies)

# ��ȡ������Ϣ
def get_produce_stat(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(appversion=appversion)
    return api_post(url="/?r=mine/produce_stat", data=body, cookies=cookies)

# ��ȡ������Ϣ
def get_privilege(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='1', appversion=appversion, ver=appversion)
    return api_post(url='/?r=usr/privilege', data=body, cookies=cookies)

# ��ȡ�豸״̬
def get_device_stat(s_type, cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='3', appversion=appversion, type=s_type)
    return api_post(url='/?r=mine/devices_stat', data=body, cookies=cookies)

# �ύ�ռ�ˮ������
def collect(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(hand='0', v='2', ver='1')
    return api_post(url='/?r=mine/collect', data=body, cookies=cookies)

# ��ȡ��ѱ�����Ϣ
def api_giftbox(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(tp='0', p='0', ps='60', t='', v='2', cmid='-1')
    return api_post(url='/?r=usr/giftbox', data=body, cookies=cookies)

# ��ȡҡ�α������
def api_shakeLeft(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict()
    return api_post(url='/?r=usr/shakeLeft', data=body, cookies=cookies)

# �ύҡ�α�������
def api_shakeGift(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='1')
    return api_post(url='/?r=usr/shakeGift', data=body, cookies=cookies)

# ��ȡҡ�α�����Ϣ
def api_stoneInfo(cookies, giftbox_id, tag):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='1', id=giftbox_id, tag=tag)
    return api_post(url='/?r=usr/stoneInfo', data=body, cookies=cookies)

# �ύ�򿪱�������
def api_openStone(cookies, sid, side, tag=None):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='1', id=str(sid), side=side)
    if tag is not None: body['tag'] = tag
    return api_post(url='/?r=usr/openStone', data=body, cookies=cookies)

# �ύ������������
def api_giveUpGift(cookies, sid, tag='0'):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='2', id=str(sid), tag=tag)
    if tag != '0': body['tag'] = tag
    return api_post(url='/?r=usr/giveUpGift', data=body, cookies=cookies)

# ��ȡ����������Ϣ
def api_sys_getEntry(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='6')
    return api_post(url='/?r=sys/getEntry', data=body, cookies=cookies)

# ��ȡ����������Ϣ
def api_steal_stolenSilverHistory(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='2', p='0', ps='20')
    return api_post(url='/?r=steal/stolenSilverHistory', data=body, cookies=cookies)

# �ύ������������
def api_steal_search(cookies, sid=None):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(v='2')
    if sid is not None: body['sid'] = str(sid)
    return api_post(url='/?r=steal/search', data=body, cookies=cookies)

# �ύ�ռ���������
def api_steal_collect(cookies, sid):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(sid=str(sid), cmid='-2', v='2')
    return api_post(url='/?r=steal/collect', data=body, cookies=cookies)

# �ύ�����������
def api_steal_summary(cookies, sid):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(sid=str(sid), v='2')
    return api_post(url='/?r=steal/summary', data=body, cookies=cookies)

# ��ȡ����ת����Ϣ
def api_getconfig(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    return api_post(url='/?r=turntable/getconfig', data=None, cookies=cookies)

# �ύ����ת������
def api_getaward(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    return api_post(url='/?r=turntable/getaward', data=None, cookies=cookies)

# ��ȡ����������Ϣ��Ѹ�����ֳ�
def api_pcSteal_info(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(appversion=appversion)
    return api_post(url='/?r=pcSteal/info', data=body, cookies=cookies)

# ��ȡ����������Ϣ��Ѹ�����ֳ�
def api_pcSteal_stolenHistory(cookies):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(appversion=appversion)
    return api_post(url='/?r=pcSteal/stolenHistory', data=body, cookies=cookies)

# �ύ������������Ѹ�����ֳ�
def api_pcSteal_steal(cookies, sid=None):
    cookies['origin'] = '4' if len(cookies.get('sessionid')) == 128 else '1'
    body = dict(appversion=appversion)
    if sid is not None: body['sid'] = str(sid)
    return api_post(url='/?r=pcSteal/steal', data=body, cookies=cookies)

# ��ȡ����洢�����Ϣ
def ubus_cd(session_id, account_id, out_params, url_param=None):
    url = "http://kjapi.peiluyou.com:5171/ubus_cd?account_id=%s&session_id=%s" % (account_id, session_id)
    if url_param is not None:
        url += url_param

    params = ["%s" % session_id] + out_params

    data = {"jsonrpc": "2.0", "id": 1, "method": "call", "params": params}
    try:
        body = dict(data=json.dumps(data), action='ubus_%d' % int(time.time() * 1000))
        with requests.Session() as s:
            s.mount('http://', HTTPAdapter(max_retries=5))
            r = s.post(url=url, data=body)
        result = r.text[r.text.index('{'):r.text.rindex('}') + 1]
        return json.loads(result)

    except requests.exceptions.RequestException as e:
        return __handle_exception(e=e)

# ����Ƿ�API����
def is_api_error(r):
    if r.get('r') == -12345:
        return True

    return False

# �ӿڹ���
def __handle_exception(e=None, rd='�ӿڹ���', r=-12345):
    if e is None:
        print(rd)
    else:
        print(e)

    b_err_count = r_session.get('api_error_count')
    if b_err_count is None:
        r_session.setex('api_error_count', '1', 60)
        return dict(r=r, rd=rd)

    err_count = int(b_err_count.decode('utf-8')) + 1
    if err_count > 200:
        r_session.setex('api_error_info', 'Ѹ�׿�API������,����ʨ���ڸ����¹��ֳ�,�����ĵȴ�.', 60)

    err_count_ttl = r_session.ttl('api_error_count')
    if err_count_ttl is None:
        err_count_ttl = 30

    r_session.setex('api_error_count', str(err_count), err_count_ttl + 1)
    return dict(r=r, rd=rd)