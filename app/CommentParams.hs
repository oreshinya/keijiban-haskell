{-# LANGUAGE DeriveGeneric #-}
module CommentParams where

import GHC.Generics (Generic)
import Data.Aeson

data Params = Params { body :: Maybe String } deriving (Generic, Show)

instance FromJSON Params
