import produce from 'immer';
import VueApollo from 'vue-apollo';
import { concatPagination } from '@apollo/client/utilities';
import getIssueStateQuery from '~/issues/show/queries/get_issue_state.query.graphql';
import createDefaultClient from '~/lib/graphql';
import typeDefs from '~/work_items/graphql/typedefs.graphql';
import { WIDGET_TYPE_MILESTONE } from '~/work_items/constants';

export const temporaryConfig = {
  typeDefs,
  cacheConfig: {
    possibleTypes: {
      LocalWorkItemWidget: ['LocalWorkItemMilestone'],
    },
    typePolicies: {
      Project: {
        fields: {
          projectMembers: {
            keyArgs: ['fullPath', 'search', 'relations', 'first'],
          },
        },
      },
      WorkItem: {
        fields: {
          mockWidgets: {
            read(widgets) {
              return (
                widgets || [
                  {
                    __typename: 'LocalWorkItemMilestone',
                    type: WIDGET_TYPE_MILESTONE,
                    nodes: [
                      {
                        dueDate: null,
                        expired: false,
                        id: 'gid://gitlab/Milestone/30',
                        title: 'v4.0',
                        // eslint-disable-next-line @gitlab/require-i18n-strings
                        __typename: 'Milestone',
                      },
                    ],
                  },
                ]
              );
            },
          },
          widgets: {
            merge(existing = [], incoming) {
              if (existing.length === 0) {
                return incoming;
              }
              return existing.map((existingWidget) => {
                const incomingWidget = incoming.find((w) => w.type === existingWidget.type);
                return incomingWidget || existingWidget;
              });
            },
          },
        },
      },
      MemberInterfaceConnection: {
        fields: {
          nodes: concatPagination(),
        },
      },
    },
  },
};

export const resolvers = {
  Mutation: {
    updateIssueState: (_, { issueType = undefined, isDirty = false }, { cache }) => {
      const sourceData = cache.readQuery({ query: getIssueStateQuery });
      const data = produce(sourceData, (draftData) => {
        draftData.issueState = { issueType, isDirty };
      });
      cache.writeQuery({ query: getIssueStateQuery, data });
    },
  },
};

export const defaultClient = createDefaultClient(resolvers, temporaryConfig);

export const apolloProvider = new VueApollo({
  defaultClient,
});
