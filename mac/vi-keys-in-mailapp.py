from AppKit import *
from Foundation import *
from Quartz.CoreGraphics import * # CGEvent
import objc

def swizzle(*args):
    """ Brilliant piece of coding from http://klep.name/programming/python/ """
    cls, SEL = args
    def decorator(func):
        oldIMP      = cls.instanceMethodForSelector_(SEL)
        def wrapper(self, *args, **kwargs):
            return func(self, oldIMP, *args, **kwargs)
        newMethod   = objc.selector(wrapper, 
                                    selector  = oldIMP.selector,
                                    signature = oldIMP.signature)
        objc.classAddMethod(cls, SEL, newMethod)
        return wrapper
    return decorator

my_keymap = { # when sorting messages in decreasing date order
    4:  115, # h maps to Fn + cursor left
    37: 119, # l maps to Fn + cursor right
    38: 124, # j maps to cursor left  - next message 
    40: 123  # k maps to cursor right - previous message
}

@swizzle(MessagesTableView, 'keyDown:')
def keyDown_(self, original, event):
    code = event.keyCode()
    NSLog('Handling key %d' % code)
    if code in my_keymap.keys():
        NSLog("Changing key %d to %d" % (code, my_keymap[code]))
        original(self, NSEvent.eventWithCGEvent_(CGEventCreateKeyboardEvent(None,my_keymap[code],True)));
    original(self, event)

MVMailBundle = objc.lookUpClass('MVMailBundle')
class TestPlugin(MVMailBundle):
    def initialize (cls):
        MVMailBundle.registerBundle()
        NSLog("TestPlugin registered with Mail")
    initialize = classmethod(initialize)
