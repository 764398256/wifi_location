from scipy.io import loadmat
import numpy as np
import pdb
file_p = '../../../data/exp6/mat/'
histo = loadmat(file_p + 'histo.mat')
histo = histo['histo']
(voxel_num, stream_num, d, nbins) = np.shape(histo)
pdb.set_trace()

from pystruct import learners
import pystruct.models as crfs
from pystruct.utils import SaveLogger
import pdb


class DataTrigger(object):
    def __init__(self, histo, gridmap):
        self.histo = histo
        self.n_nodes = n_nodes
        self.n_features = n_features
    
    def nodes(self, gridmap):
        

data_train = pickle.load(open("data_train.pickle"))
C = 0.01

n_states = 21
print("number of samples: %s" % len(data_train['X']))
class_weights = 1. / np.bincount(np.hstack(data_train['Y']))
class_weights *= 21. / np.sum(class_weights)
print(class_weights)

pdb.set_trace()
model = crfs.EdgeFeatureGraphCRF(inference_method='qpbo',
                                 class_weight=class_weights,
                                 symmetric_edge_features=[0, 1],
                                 antisymmetric_edge_features=[2])

experiment_name = "edge_features_one_slack_trainval_%f" % C

ssvm = learners.NSlackSSVM(
    model, verbose=2, C=C, max_iter=100000, n_jobs=-1,
    tol=0.0001, show_loss_every=5,
    logger=SaveLogger(experiment_name + ".pickle", save_every=100),
    inactive_threshold=1e-3, inactive_window=10, batch_size=100)
ssvm.fit(data_train['X'], data_train['Y'])
pdb.set_trace()

data_val = pickle.load(open("data_val_dict.pickle"))
y_pred = ssvm.predict(data_val['X'])

# we throw away void superpixels and flatten everything
y_pred, y_true = np.hstack(y_pred), np.hstack(data_val['Y'])
y_pred = y_pred[y_true != 255]
y_true = y_true[y_true != 255]

print("Score on validation set: %f" % np.mean(y_true == y_pred))


