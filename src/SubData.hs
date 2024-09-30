{-# LANGUAGE DefaultSignatures #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE ViewPatterns #-}

module SubData where

import ClassyPrelude.Yesod

data SubApp = SubApp

mkYesodSubData "SubApp" [parseRoutes|
/hello HelloR GET
|]

type Form a = forall m. YesodSubApp m =>
  Html -> MForm (SubHandlerFor SubApp m) (FormResult a, WidgetFor m ())

class (Yesod m, RenderMessage m FormMessage) => YesodSubApp m

newSubApp :: MonadIO m => m SubApp
newSubApp = pure SubApp
