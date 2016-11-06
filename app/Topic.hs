{-# LANGUAGE DeriveGeneric #-}
module Topic where

import GHC.Generics (Generic)
import Data.Aeson

data Topic = Topic { id :: Int, name :: String } deriving (Generic, Show)

instance ToJSON Topic
