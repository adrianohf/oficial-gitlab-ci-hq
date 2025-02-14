import * as utils from '~/blob/utils';
import Editor from '~/editor/source_editor';

jest.mock('~/editor/source_editor');

describe('Blob utilities', () => {
  describe('initSourceEditor', () => {
    let editorEl;
    const blobPath = 'foo.txt';
    const blobContent = 'Foo bar';
    const blobGlobalId = 'snippet_777';

    beforeEach(() => {
      editorEl = document.createElement('div');
    });

    describe('Monaco editor', () => {
      it('initializes the Source Editor', () => {
        utils.initSourceEditor({ el: editorEl });
        expect(Editor).toHaveBeenCalledWith({
          scrollbar: {
            alwaysConsumeMouseWheel: false,
          },
        });
      });

      it.each([[{}], [{ blobPath, blobContent, blobGlobalId }]])(
        'creates the instance with the passed parameters %s',
        (extraParams) => {
          const params = {
            el: editorEl,
            ...extraParams,
          };

          expect(Editor.prototype.createInstance).not.toHaveBeenCalled();

          utils.initSourceEditor(params);

          expect(Editor.prototype.createInstance).toHaveBeenCalledWith(params);
        },
      );
    });
  });
  describe('getPageParamValue', () => {
    it('returns empty string if no perPage parameter is provided', () => {
      const pageParamValue = utils.getPageParamValue(5);
      expect(pageParamValue).toEqual('');
    });
    it('returns empty string if page is equal 1', () => {
      const pageParamValue = utils.getPageParamValue(1000, 1000);
      expect(pageParamValue).toEqual('');
    });
    it('returns correct page parameter value', () => {
      const pageParamValue = utils.getPageParamValue(1001, 1000);
      expect(pageParamValue).toEqual(2);
    });
    it('accepts strings as a parameter and returns correct result', () => {
      const pageParamValue = utils.getPageParamValue('1001', '1000');
      expect(pageParamValue).toEqual(2);
    });
  });
  describe('getPageSearchString', () => {
    it('returns empty search string if page parameter is empty value', () => {
      const path = utils.getPageSearchString('/blamePath', '');
      expect(path).toEqual('');
    });
    it('returns correct search string if value is provided', () => {
      const searchString = utils.getPageSearchString('/blamePath', 3);
      expect(searchString).toEqual('?page=3');
    });
  });
});
