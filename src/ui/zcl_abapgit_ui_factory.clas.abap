CLASS zcl_abapgit_ui_factory DEFINITION
  PUBLIC
  CREATE PRIVATE
  GLOBAL FRIENDS zcl_abapgit_ui_injector .

  PUBLIC SECTION.

    CLASS-METHODS get_popups
      RETURNING
        VALUE(ri_popups) TYPE REF TO zif_abapgit_popups .
    CLASS-METHODS get_tag_popups
      RETURNING
        VALUE(ri_tag_popups) TYPE REF TO zif_abapgit_tag_popups .
    CLASS-METHODS get_gui_functions
      RETURNING
        VALUE(ri_gui_functions) TYPE REF TO zif_abapgit_gui_functions .
    CLASS-METHODS get_gui
      RETURNING
        VALUE(ro_gui) TYPE REF TO zcl_abapgit_gui
      RAISING
        zcx_abapgit_exception .
    CLASS-METHODS get_gui_services
      RETURNING
        VALUE(ri_gui_services) TYPE REF TO zif_abapgit_gui_services
      RAISING
        zcx_abapgit_exception .
    CLASS-METHODS get_frontend_services
      RETURNING
        VALUE(ri_fe_serv) TYPE REF TO zif_abapgit_frontend_services .
  PROTECTED SECTION.
  PRIVATE SECTION.

    CLASS-DATA gi_popups TYPE REF TO zif_abapgit_popups .
    CLASS-DATA gi_tag_popups TYPE REF TO zif_abapgit_tag_popups .
    CLASS-DATA gi_gui_functions TYPE REF TO zif_abapgit_gui_functions .
    CLASS-DATA go_gui TYPE REF TO zcl_abapgit_gui .
    CLASS-DATA gi_fe_services TYPE REF TO zif_abapgit_frontend_services .
    CLASS-DATA gi_gui_services TYPE REF TO zif_abapgit_gui_services .

    CLASS-METHODS init_asset_manager
      RETURNING
        VALUE(ro_asset_man) TYPE REF TO zcl_abapgit_gui_asset_manager
      RAISING
        zcx_abapgit_exception .
ENDCLASS.



CLASS ZCL_ABAPGIT_UI_FACTORY IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_FRONTEND_SERVICES
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RI_FE_SERV                     TYPE REF TO ZIF_ABAPGIT_FRONTEND_SERVICES
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_frontend_services.

    IF gi_fe_services IS INITIAL.
      CREATE OBJECT gi_fe_services TYPE zcl_abapgit_frontend_services.
    ENDIF.

    ri_fe_serv = gi_fe_services.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_GUI
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_GUI                         TYPE REF TO ZCL_ABAPGIT_GUI
* | [!CX!] ZCX_ABAPGIT_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_gui.

    DATA:
      li_hotkey_ctl TYPE REF TO zif_abapgit_gui_hotkey_ctl,
      li_router     TYPE REF TO zif_abapgit_gui_event_handler,
      li_asset_man  TYPE REF TO zif_abapgit_gui_asset_manager.

    DATA lo_html_preprocessor TYPE REF TO zcl_abapgit_gui_html_processor.

    IF go_gui IS INITIAL.
      li_asset_man ?= init_asset_manager( ).

      CREATE OBJECT lo_html_preprocessor EXPORTING ii_asset_man = li_asset_man.
      lo_html_preprocessor->preserve_css( 'css/ag-icons.css' ).
      lo_html_preprocessor->preserve_css( 'css/common.css' ).

      CREATE OBJECT li_router TYPE zcl_abapgit_gui_router.
      CREATE OBJECT li_hotkey_ctl TYPE zcl_abapgit_hotkeys.

      CREATE OBJECT go_gui
        EXPORTING
          io_component      = li_router
          ii_hotkey_ctl     = li_hotkey_ctl
          ii_html_processor = lo_html_preprocessor
          ii_asset_man      = li_asset_man.
    ENDIF.
    ro_gui = go_gui.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_GUI_FUNCTIONS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RI_GUI_FUNCTIONS               TYPE REF TO ZIF_ABAPGIT_GUI_FUNCTIONS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_gui_functions.

    IF gi_gui_functions IS INITIAL.
      CREATE OBJECT gi_gui_functions TYPE zcl_abapgit_gui_functions.
    ENDIF.

    ri_gui_functions = gi_gui_functions.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_GUI_SERVICES
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RI_GUI_SERVICES                TYPE REF TO ZIF_ABAPGIT_GUI_SERVICES
* | [!CX!] ZCX_ABAPGIT_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_gui_services.
    IF gi_gui_services IS NOT BOUND.
      gi_gui_services ?= get_gui( ).
    ENDIF.
    ri_gui_services = gi_gui_services.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_POPUPS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RI_POPUPS                      TYPE REF TO ZIF_ABAPGIT_POPUPS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_popups.

    IF gi_popups IS INITIAL.
      CREATE OBJECT gi_popups TYPE zcl_abapgit_popups.
    ENDIF.

    ri_popups = gi_popups.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_ABAPGIT_UI_FACTORY=>GET_TAG_POPUPS
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RI_TAG_POPUPS                  TYPE REF TO ZIF_ABAPGIT_TAG_POPUPS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD get_tag_popups.

    IF gi_tag_popups IS INITIAL.
      CREATE OBJECT gi_tag_popups TYPE zcl_abapgit_tag_popups.
    ENDIF.

    ri_tag_popups = gi_tag_popups.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_ABAPGIT_UI_FACTORY=>INIT_ASSET_MANAGER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_ASSET_MAN                   TYPE REF TO ZCL_ABAPGIT_GUI_ASSET_MANAGER
* | [!CX!] ZCX_ABAPGIT_EXCEPTION
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD init_asset_manager.

    DATA lo_buf TYPE REF TO lcl_string_buffer.

    CREATE OBJECT lo_buf.
    CREATE OBJECT ro_asset_man.

    " @@abapmerge include zabapgit_css_common.w3mi.data.css > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'css/common.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZABAPGIT_CSS_COMMON'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_css_theme_default.w3mi.data.css > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'css/theme-default.css'
      iv_type      = 'text/css'
      iv_cachable  = abap_false
      iv_mime_name = 'ZABAPGIT_CSS_THEME_DEFAULT'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_css_theme_dark.w3mi.data.css > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'css/theme-dark.css'
      iv_type      = 'text/css'
      iv_cachable  = abap_false
      iv_mime_name = 'ZABAPGIT_CSS_THEME_DARK'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_css_theme_belize_blue.w3mi.data.css > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'css/theme-belize-blue.css'
      iv_type      = 'text/css'
      iv_cachable  = abap_false
      iv_mime_name = 'ZABAPGIT_CSS_THEME_BELIZE_BLUE'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_js_common.w3mi.data.js > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'js/common.js'
      iv_type      = 'text/javascript'
      iv_mime_name = 'ZABAPGIT_JS_COMMON'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_icon_font_css.w3mi.data.css > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'css/ag-icons.css'
      iv_type      = 'text/css'
      iv_mime_name = 'ZABAPGIT_ICON_FONT_CSS'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include-base64 zabapgit_icon_font.w3mi.data.woff > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'font/ag-icons.woff'
      iv_type      = 'font/woff'
      iv_mime_name = 'ZABAPGIT_ICON_FONT'
      iv_base64    = lo_buf->join_and_flush( ) ).

    " see https://github.com/larshp/abapGit/issues/201 for source SVG

    " @@abapmerge include zabapgit_logo.w3mi.data.svg > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'img/logo'
      iv_type      = 'image/svg'
      iv_mime_name = 'ZABAPGIT_LOGO'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

    " @@abapmerge include zabapgit_logo_dark.w3mi.data.svg > lo_buf->add( '$$' ).
    ro_asset_man->register_asset(
      iv_url       = 'img/logo_dark'
      iv_type      = 'image/svg'
      iv_mime_name = 'ZABAPGIT_LOGO_DARK'
      iv_inline    = lo_buf->join_w_newline_and_flush( ) ).

  ENDMETHOD.
ENDCLASS.
