#coding:UTF-8  
''''' 
@author: shenhan 
 '''  
import scipy.io as scio  
from sklearn.neighbors import NearestNeighbors
from scipy.stats.stats import pearsonr   
import numpy as np
import math
from numpy import linalg as LA

class Trainer(object):
    def __init__(self, train_data, test_data, labels):
        self.error = 0
        self.train_data = train_data
        self.test_data = test_data
        self.labels = labels

    def distance(self, x_real, y_real, x_exp, y_exp):
        return np.sqrt( (x_real - x_exp) ** 2 + (y_real - y_exp) ** 2 )
        
    def train(self, method = 'knn', args={}):
        options = {
        'knn': self.knn,
        'bayes': self.bayes
        }
        indices = options[method](self.train_data, self.test_data, args)
        correct, error_arr= self.analysis(indices,self.labels)
        test_sample = np.size(indices)
        print 'Classification method %s:\n'\
              'Correctly classify %d/%d test samples'%(method, correct, test_sample)
        print 'Total error: %f m \n'\
              'Average error: %f m\n' \
              'Variation: %f \n' \
              'Max error %f m\n' \
              'Min error %f m '%( sum(error_arr), sum(error_arr)/test_sample, np.var(error_arr), max(error_arr), min(error_arr) )


    def knn(self, train_data, test_data, args):
        if 'n_neighbors' in args:
            neighbors_num = args['n_neighbors']
        else:
            neighbors_num = 1
        if 'algorithm' in args:
            algorithm = args['algorithm']
        else:
            algorithm = 'ball_tree'
        nbrs = NearestNeighbors(n_neighbors=neighbors_num, algorithm=algorithm).fit(train_data)
        self.trainer = nbrs.kneighbors
        distances, indices = self.trainer(test_data)
        return [ t[0] for t in indices ]

    def bayes(self, train_data, test_data, args):
        corr_train = [[]]
        if 'corr_train' in args:
            corr_train = args['corr_train']
        dim = np.shape(train_data)[1] 
        indices = []
        for htest in test_data:
            corr = [ pearsonr(htrain, htest)[0] for htrain in train_data]
            pl = corr / sum(corr)
            phl = [ 1/np.sqrt((2*math.pi)**dim* LA.norm(corr_train))*np.exp(-1/2*np.dot(np.dot((htest-htrain),LA.inv(corr_train[:,:,i])),np.transpose(htest-htrain))) for i, htrain in enumerate(train_data) ]
            indices.append(np.argmax( phl*pl ))
        return indices

    def analysis(self, indices, labels):
        correct_cls = [ i == t  for i, t in enumerate(indices)]
        err_arr = [ self.distance( labels[t][0], labels[t][1], labels[i][0], labels[i][1])  for i,t in enumerate(indices)]
        return  sum(correct_cls), err_arr 


if __name__ == '__main__':
    data_path='../../data/exp3/'
    file_folder=data_path+'mat/'
    figure_folder=data_path+ 'figure/'
    mat_folder=data_path+'mat/'

    trainf_path = mat_folder+ 'features_train.mat'
    testf_path = mat_folder + 'features_test.mat'
    label_path = mat_folder + 'labels.mat'
    corrtrain_path = mat_folder + 'corr_train.mat'
    trainf = scio.loadmat(trainf_path)['features_train'] 
    testf = scio.loadmat(testf_path)['features_test'] 
    labels = scio.loadmat(label_path)['labels']
    trainc = scio.loadmat(corrtrain_path)['corr_train']
    
    cls = Trainer(np.transpose(trainf), np.transpose(testf), np.transpose(labels))
    args = {'n_neighbors':1, 'corr_train':trainc}
    cls.train('bayes', args)
    print '========================================================'
    cls.train('knn', args)
    



