
#from twisted.internet.defer import inlineCallbacks
#import re
#
#@inlineCallbacks
#def pre_envelope_send(ui, dbm):
#    e = ui.current_buffer.envelope
#    if re.match('.*[Aa]ttach', e.body, re.DOTALL) and not e.attachments:
#        msg = 'No attachment included... send anyway?'
#        if not (yield ui.choice(msg, select='yes')) == 'yes':
#            raise Exception()

def pre_envelope_send(ui, dbm):
    ADDR = "edavis@broadcom.com"
    from_fulladdr = ui.current_buffer.envelope.get_all("From")[0]
    if ADDR in from_fulladdr:
        ui.current_buffer.envelope.add("Bcc:", ADDR)

