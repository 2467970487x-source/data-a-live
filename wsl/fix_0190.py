W = '/mnt/d/workbuddy/ios/data-a-live-main/wsl/'

# GPU watch for 10 minutes, the standing SMMU FSR bit logged once (bsd/dev/pandora_gpu.c).
open('bsd/dev/pandora_gpu.c', 'w').write(open(W + 'pandora_gpu.c').read().replace('\r', ''))
print('patched')
