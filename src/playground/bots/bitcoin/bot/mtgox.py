# https://bitbucket.org/nitrous/mtgox-api
# Basic MtGox API v2 implementation 
# Some code inspired by http://pastebin.com/aXQfULyq
# Don't request results more often than every 10 seconds, you risk being blocked by the anti-DDoS filters

import time,hmac,base64,hashlib,urllib,urllib2,json
from conf import key, secret, proxy
import sys

try:
    import urllib3
    http = urllib3.PoolManager()
    # added by tiz
    print "Attention proxy not installed"
        
except:
    http = None
    # added by tiz
    # print "Unexpected error:", sys.exc_info()[0]
        
class mtgox:
    timeout = 15
    tryout = 8

    def __init__(self, key='', secret='', agent='btc_bot'):
        self.key, self.secret, self.agent = key, secret, agent
        self.time = {'init': time.time(), 'req': time.time()}
        self.reqs = {'max': 10, 'window': 10, 'curr': 0}
        self.base = 'https://mtgox.com/api/2/'
        self.agent = 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.26 Safari/537.4'

    def throttle(self):
        # check that in a given time window (10 seconds),
        # no more than a maximum number of requests (10)
        # have been sent, otherwise sleep for a bit
        diff = time.time() - self.time['req']
        if diff > self.reqs['window']:
            self.reqs['curr'] = 0
            self.time['req'] = time.time()
        self.reqs['curr'] += 1
        if self.reqs['curr'] > self.reqs['max']:
            print 'Request limit reached...'
            time.sleep(self.reqs['window'] - diff)

    def makereq(self, path, data):
        # bare-bones hmac rest sign
        return urllib2.Request(self.base + path, data, self.get_headers(path, data))

    def get_headers(self, path, data):
        return {
            'User-Agent': self.agent,
            'Rest-Key': self.key,
            'Rest-Sign': base64.b64encode(str(hmac.new(base64.b64decode(self.secret), path + chr(0) + data, hashlib.sha512).digest())),
        }

    def req(self, path, inp={}):
        t0 = time.time()
        tries = 0
        while True:
            # check if have been making too many requests
            self.throttle()

            try:
                # send request to mtgox
                inp['nonce'] = str(int(time.time() * 1e6))
                inpstr = urllib.urlencode(inp.items())
                if http:
                    print 'i should not be here'
                    headers = self.get_headers(path, inpstr)
                    headers["Content-type"] = "application/x-www-form-urlencoded"
                    r = http.urlopen('POST', self.base+path, body=inpstr, headers=headers)
                    output = json.loads(r.data)
                else:
                    req = self.makereq(path, inpstr)
                    
                    # added by tiz
                    if proxy:
                        myproxy = urllib2.ProxyHandler({'https': proxy})
                        opener = urllib2.build_opener(myproxy)
                        opener.addheaders = [('User-agent', 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.26 Safari/537.4')]
                        urllib2.install_opener(opener)
                        #print 'proxy installed '+proxy
                    
                    response = urllib2.urlopen(req, inpstr)
                    output = json.load(response)

                if 'error' in output:
                    raise ValueError(output['error'])

                return output

            except urllib2.HTTPError, e: 
                output = json.load(e)
                print "Error: %s" % output['error']

            except Exception as e:
                print "Error: %s" % e


            # don't wait too long
            tries += 1
            if time.time() - t0 > self.timeout or tries > self.tryout:
                raise Exception('Timeout')

if __name__=='__main__':
    gox = mtgox()
    try:
        bid_price = gox.req('BTCUSD/money/order/quote', {'type':'bid','amount':100000000})
        print "Current USD Bid Price: %f" % (bid_price['data']['amount'] / 1e5)
    except Exception as e:
        print "Error - %s" % e



