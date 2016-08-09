from scipy.io import loadmat
import numpy as np
import pdb
file_p = '../../../data/exp6/mat/'
histo = loadmat(file_p + 'histo.mat')
histo = histo['histo']
(voxel_num, stream_num, d, nbins) = np.shape(histo)
pdb.set_trace()

