-----------------------------------------------------------------------------
-- |
-- Module      :  Handler.Home.LuciConnect
-- Copyright   :  (c) Artem Chirkin
-- License     :  MIT
--
-- Maintainer  :  Artem Chirkin <chirkin@arch.ethz.ch>
-- Stability   :  experimental
--
-----------------------------------------------------------------------------

module Handler.Home.LuciConnect
  ( luciConnectPane
  ) where

import Import
import Text.Julius

luciConnectPane :: Handler (Text,Text, Widget)
luciConnectPane = do
  luciConnectedClass <- newIdent
  luciDisconnectedClass <- newIdent
  return . (,,) luciConnectedClass luciDisconnectedClass $ do
    connectButton <- newIdent
    luciProxyUrl <- newIdent
    luciConnectedInfo <- newIdent

    hiddenPaneClass  <- newIdent
    visiblePaneClass <- newIdent

    let connectForm =
          [hamlet|
           <div style="margin: 10px 0 0 20px;">
            <div>
              Connect to Luci
            <div>
              <a.btn.btn-red.waves-attach.waves-light.waves-effect ##{connectButton}">
                connect
              <div.form-group.form-group-label.control-highlight style="display: inline-block; margin: 12px 0px -12px 4px;">
                <label.floating-label for="#{luciProxyUrl}">Host address
                <input.form-control ##{luciProxyUrl} type="url" value="ws://localhost/luci">
          |]
        connectedInfo =
          [hamlet|
            <div style="margin: 10px 0 0 20px;">
              Connected to Luci at
              <p ##{luciConnectedInfo} style="display: inline;">
           |]

    toWidgetHead
      [cassius|
       .#{hiddenPaneClass}
         display: none

       .#{visiblePaneClass}
         display: block
         margin: 0
         padding: 0
      |]
    toWidgetHead
      [julius|
        /** Registers one callback; comes from Handler.Home.PanelServices.
         *  onClick :: JSString -> IO () -- address of websocket host
         *  return :: IO ()
         */
        function registerUserConnectToLuci(onClick){
          document.getElementById('#{rawJS connectButton}').onclick = function(){
            var url = document.getElementById('#{rawJS luciProxyUrl}').value;
            if (url) {onClick(url);}
          };
        }

        /** Display "luci connected message"; comes from Handler.Home.PanelServices.
         *  connectedHost :: JSString -- address of websocket host
         *  return :: IO ()
         */
        function showLuciConnected(connectedHost){
          Array.prototype.slice.call(
            document.getElementsByClassName('#{rawJS luciDisconnectedClass}')).forEach(function(e){
               e.className = "#{rawJS luciDisconnectedClass} #{rawJS hiddenPaneClass}";
             });
          document.getElementById('#{rawJS luciConnectedInfo}').innerText = connectedHost;
          Array.prototype.slice.call(
            document.getElementsByClassName('#{rawJS luciConnectedClass}')).forEach(function(e){
               e.className = "#{rawJS luciConnectedClass} #{rawJS visiblePaneClass}";
             });
        }

        /** Display "connect to luci" form; comes from Handler.Home.PanelServices.
         *  defaultHost :: JSString -- default address of websocket host
         *  return :: IO ()
         */
        function showLuciConnectForm(defaultHost){
          Array.prototype.slice.call(
            document.getElementsByClassName('#{rawJS luciConnectedClass}')).forEach(function(e){
               e.className = "#{rawJS luciConnectedClass} #{rawJS hiddenPaneClass}";
             });
          if (defaultHost) {
            document.getElementById('#{rawJS luciProxyUrl}').value = defaultHost;
          } else {
            document.getElementById('#{rawJS luciProxyUrl}').value = "";
          }
          Array.prototype.slice.call(
            document.getElementsByClassName('#{rawJS luciDisconnectedClass}')).forEach(function(e){
               e.className = "#{rawJS luciDisconnectedClass} #{rawJS visiblePaneClass}";
             });
        }
      |]
    toWidgetBody
      [hamlet|
        <div .#{luciDisconnectedClass}>
          ^{connectForm}
        <div .#{luciConnectedClass}>
          ^{connectedInfo}
      |]
