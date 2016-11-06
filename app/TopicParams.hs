{-# LANGUAGE DeriveGeneric #-}
module TopicParams where

import GHC.Generics (Generic)
import Data.Aeson

data Params = Params { name :: Maybe String } deriving (Generic, Show)

instance FromJSON Params
