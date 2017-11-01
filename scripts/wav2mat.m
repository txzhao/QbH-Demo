function wav2mat(path, winlen)

[y, fs] = audioread(path);
seq = GetMusicFeatures(y, fs, winlen);
st = PostProcess(seq, false);
save([strrep(path,'.wav','') '.mat'], 'y', 'st');