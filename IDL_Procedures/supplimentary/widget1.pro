PRO widget1_event, ev 
  IF ev.SELECT THEN WIDGET_CONTROL, ev.TOP, /DESTROY 
END 
 
PRO widget1 
  base = WIDGET_BASE(/COLUMN) 
  side = Widget_Base(/Row)
  button = WIDGET_BUTTON(base, value='Done') 
  button = Widget_Button(side, value='dooing')
  WIDGET_CONTROL, base, /REALIZE 
  XMANAGER, 'widget1', base 
END