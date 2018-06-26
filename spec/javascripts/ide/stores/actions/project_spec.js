import {
  refreshLastCommitData,
  showBranchNotFoundError,
  createNewBranchFromDefault,
} from '~/ide/stores/actions';
import store from '~/ide/stores';
import projectActions from '~/ide/stores/actions/project';
import service from '~/ide/services';
import api from '~/api';
import { resetStore } from '../../helpers';
import testAction from '../../../helpers/vuex_action_helper';

describe('IDE store project actions', () => {
  beforeEach(() => {
    store.state.projects['abc/def'] = {};
  });

  afterEach(() => {
    resetStore(store);
  });

  describe('refreshLastCommitData', () => {
    beforeEach(() => {
      store.state.currentProjectId = 'abc/def';
      store.state.currentBranchId = 'master';
      store.state.projects['abc/def'] = {
        id: 4,
        branches: {
          master: {
            commit: null,
          },
        },
      };
      spyOn(service, 'getBranchData').and.returnValue(
        Promise.resolve({
          data: {
            commit: { id: '123' },
          },
        }),
      );
    });

    it('calls the service', done => {
      store
        .dispatch('refreshLastCommitData', {
          projectId: store.state.currentProjectId,
          branchId: store.state.currentBranchId,
        })
        .then(() => {
          expect(service.getBranchData).toHaveBeenCalledWith('abc/def', 'master');

          done();
        })
        .catch(done.fail);
    });

    it('commits getBranchData', done => {
      testAction(
        refreshLastCommitData,
        {
          projectId: store.state.currentProjectId,
          branchId: store.state.currentBranchId,
        },
        store.state,
        [
          {
            type: 'SET_BRANCH_COMMIT',
            payload: {
              projectId: 'abc/def',
              branchId: 'master',
              commit: { id: '123' },
            },
          },
        ], // mutations
        [
          {
            type: 'getLastCommitPipeline',
            payload: {
              projectId: 'abc/def',
              projectIdNumber: store.state.projects['abc/def'].id,
              branchId: 'master',
            },
          },
        ], // action
        done,
      );
    });
  });

  describe('showBranchNotFoundError', () => {
    it('dispatches setErrorMessage', done => {
      testAction(
        showBranchNotFoundError,
        'master',
        null,
        [],
        [
          {
            type: 'setErrorMessage',
            payload: {
              text: "Branch <strong>master</strong> was not found in this project's repository.",
              action: 'createNewBranchFromDefault',
              actionText: 'Create branch',
              actionPayload: 'master',
            },
          },
        ],
        done,
      );
    });
  });

  describe('createNewBranchFromDefault', () => {
    it('calls API', done => {
      spyOn(api, 'createBranch').and.returnValue(Promise.resolve());
      spyOnDependency(projectActions, 'refreshCurrentPage');

      createNewBranchFromDefault(
        {
          state: {
            currentProjectId: 'project-path',
          },
          getters: {
            currentProject: {
              default_branch: 'master',
            },
          },
        },
        'new-branch-name',
      );

      setTimeout(() => {
        expect(api.createBranch).toHaveBeenCalledWith('project-path', {
          ref: 'master',
          branch: 'new-branch-name',
        });

        done();
      });
    });

    it('reloads window', done => {
      spyOn(api, 'createBranch').and.returnValue(Promise.resolve());
      const refreshSpy = spyOnDependency(projectActions, 'refreshCurrentPage');

      createNewBranchFromDefault(
        {
          state: {
            currentProjectId: 'project-path',
          },
          getters: {
            currentProject: {
              default_branch: 'master',
            },
          },
        },
        'new-branch-name',
      );

      setTimeout(() => {
        expect(refreshSpy).toHaveBeenCalled();

        done();
      });
    });
  });
});
