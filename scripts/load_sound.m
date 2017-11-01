function [st, Y, FS] = load_sound(filename)

winlen = 0.03;
[Y, FS] = audioread(filename);
frIseq = GetMusicFeatures(Y, FS, winlen);
st = PostProcess(frIseq, false);