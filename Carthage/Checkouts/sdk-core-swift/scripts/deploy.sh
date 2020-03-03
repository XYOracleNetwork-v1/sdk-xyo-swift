pod trunk register arie.trouw@xyo.network 'Deploy' --description='Deploy Script'
pod lib lint
pod --allow-warnings trunk push sdk-core-swift.podspec