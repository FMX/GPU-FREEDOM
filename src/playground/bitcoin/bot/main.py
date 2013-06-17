import sys

from func import *
from stablebot import StableBot
from rampbot import RampBot
from mtgox_key import version

if __name__=='__main__':
    try:
        if sys.argv[1]=='wallets':
            wallets = get_wallets()
            for wallet in wallets:
                print wallet, wallets[wallet]['Balance']['display']

        elif sys.argv[1]=='orders':
            for order in get_orders():
                print order['oid'], order['status'], order['type'], 'price: ', order['price']['display'], \
                    'amount: ', order['amount']['display']

        elif sys.argv[1]=='buy':
            amount = int(float(sys.argv[2])*rbtc)
            if len(sys.argv)>=4:
                price = int(float(sys.argv[3])*rusd)
            else:
                price = None 
            print buy(amount, price)

        elif sys.argv[1]=='sell':
            amount = int(float(sys.argv[2])*rbtc)
            if len(sys.argv)>=4:
                price = int(float(sys.argv[3])*rusd)
            else:
                price = None 
            print sell(amount, price)

        elif sys.argv[1]=='cancel':
            order_id = sys.argv[2]
            print cancel(order_id)

        elif sys.argv[1]=='cancel_all':
            print cancel_all()

        elif sys.argv[1]=='result':
            ctype = sys.argv[2]    #bid or ask
            order_id = sys.argv[3]
            print get_order_result(ctype, order_id)

        elif sys.argv[1]=='ticker':
            res = ticker2()
            for k in ['last', 'high', 'low', 'avg', 'vwap', 'buy', 'sell', 'vol']:
                print k, res[k]['display_short']

        elif sys.argv[1]=='lag':
            print lag()

        elif sys.argv[1]=='quote':
            ctype = sys.argv[2]    #bid or ask
            amount = int(float(sys.argv[3])*rbtc)
            print quote(ctype, amount)

        elif sys.argv[1]=='stablebot':
            max_btc = int(float(sys.argv[2])*rbtc)
            max_usd = int(float(sys.argv[3])*rusd)
            init_action = sys.argv[4] #sell, buy
            init_price = int(float(sys.argv[5])*rusd)
            trigger_percent = float(sys.argv[6])
            bot = StableBot(max_btc, max_usd, init_action, init_price, trigger_percent)
            bot.run()
        elif sys.argv[1]=='rampbot':
            max_btc = int(float(sys.argv[2])*rbtc)
            max_usd = int(float(sys.argv[3])*rusd)
            init_action = sys.argv[4] #sell, buy
            init_price = int(float(sys.argv[5])*rusd)
            trigger_percent = float(sys.argv[6])
            rampbot = RampBot(max_btc, max_usd, init_action, init_price, trigger_percent)
            rampbot.run()
        elif sys.argv[1]=='help':
            print "***********************"
            print "* tiz bitcoin bot "+version+' *'
            print "***********************"
            print "Adapted from perol's funny bitcoinbot available "
            print "at http://github.com/perol/funny-bot-bitcoin"
            print ""
            print "Usage:"
            print " python main.py ticker"
            print " python main.py wallets"
            print " python main.py orders"
            print " python main.py stablebot 0.01 2 buy 110.0 0.01"
            print " python main.py rampbot 0.01 2 buy 110.0 0.01"
            
        else:
            pass

    except Exception as e:
        print now(), "Error - ", get_err()


