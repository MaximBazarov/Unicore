def setup_main_pods
    pod 'FunctionalFoundation'
end

target 'Unicore' do
    platform :osx, '10.10'
    setup_main_pods

    target 'UnicoreTests' do
        inherit! :search_paths
    end
end

target 'Unicore iOS' do
    platform :ios, '9.0'
    setup_main_pods

    target 'Unicore iOSTests' do
        inherit! :search_paths
    end
end

target 'Unicore tvOS' do

    platform :tvos, '9.0'
    setup_main_pods

    target 'Unicore tvOSTests' do
        inherit! :search_paths
    end

end
