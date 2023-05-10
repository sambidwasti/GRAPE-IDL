;  Playing with Widget
;  Sambid Wasti
;  Interesting, fun and awesome stuffs.
;  Very Weird way of showing the buttons. 
Pro Widget_Example_event, ev
    COMPILE_OPT hidden
    WIDGET_CONTROL, ev.TOP, GET_UVALUE=stash

  ; If the user clicked the 'Done' button, destroy the widgets.
  IF (ev.ID EQ stash.cDone) THEN WIDGET_CONTROL, ev.TOP, /DESTROY
End


Pro Widget_Example
    Pos = WIDGET_BASE(/COLUMN, /BASE_ALIGN_TOP)
    
    wControl = WIDGET_BASE(Pos, /ROW)
    cDone = WIDGET_BUTTON(wControl, VALUE='Done')

    stash = { cDone:cDone }
    WIDGET_CONTROL, Pos, /REALIZE
    WIDGET_CONTROL, Pos, SET_UVALUE=stash
    XMANAGER, 'Widget_Example', Pos, /NO_BLOCK
End

