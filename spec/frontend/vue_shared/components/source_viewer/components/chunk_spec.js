import { GlIntersectionObserver } from '@gitlab/ui';
import { shallowMountExtended } from 'helpers/vue_test_utils_helper';
import Chunk from '~/vue_shared/components/source_viewer/components/chunk.vue';
import ChunkLine from '~/vue_shared/components/source_viewer/components/chunk_line.vue';
import { scrollToElement } from '~/lib/utils/common_utils';

jest.mock('~/lib/utils/common_utils');

const DEFAULT_PROPS = {
  chunkIndex: 2,
  isHighlighted: false,
  content: '// Line 1 content \n // Line 2 content',
  startingFrom: 140,
  totalLines: 50,
  language: 'javascript',
  blamePath: 'blame/file.js',
};

const hash = '#L142';

describe('Chunk component', () => {
  let wrapper;
  let idleCallbackSpy;

  const createComponent = (props = {}) => {
    wrapper = shallowMountExtended(Chunk, {
      mocks: { $route: { hash } },
      propsData: { ...DEFAULT_PROPS, ...props },
    });
  };

  const findIntersectionObserver = () => wrapper.findComponent(GlIntersectionObserver);
  const findChunkLines = () => wrapper.findAllComponents(ChunkLine);
  const findLineNumbers = () => wrapper.findAllByTestId('line-number');
  const findContent = () => wrapper.findByTestId('content');

  beforeEach(() => {
    idleCallbackSpy = jest.spyOn(window, 'requestIdleCallback').mockImplementation((fn) => fn());
    createComponent();
  });

  afterEach(() => wrapper.destroy());

  describe('Intersection observer', () => {
    it('renders an Intersection observer component', () => {
      expect(findIntersectionObserver().exists()).toBe(true);
    });

    it('emits an appear event when intersection-observer appears', () => {
      findIntersectionObserver().vm.$emit('appear');

      expect(wrapper.emitted('appear')).toEqual([[DEFAULT_PROPS.chunkIndex]]);
    });

    it('does not emit an appear event is isHighlighted is true', () => {
      createComponent({ isHighlighted: true });
      findIntersectionObserver().vm.$emit('appear');

      expect(wrapper.emitted('appear')).toEqual(undefined);
    });
  });

  describe('rendering', () => {
    it('does not render a Chunk Line component if isHighlighted is false', () => {
      expect(findChunkLines().length).toBe(0);
    });

    it('does not render simplified line numbers and content if browser is not in idle state', () => {
      idleCallbackSpy.mockRestore();
      createComponent();

      expect(findLineNumbers()).toHaveLength(0);
      expect(findContent().exists()).toBe(false);
    });

    it('renders simplified line numbers and content if isHighlighted is false', () => {
      expect(findLineNumbers().length).toBe(DEFAULT_PROPS.totalLines);

      expect(findLineNumbers().at(0).attributes('id')).toBe(`L${DEFAULT_PROPS.startingFrom + 1}`);

      expect(findContent().text()).toBe(DEFAULT_PROPS.content);
    });

    it('renders Chunk Line components if isHighlighted is true', () => {
      const splitContent = DEFAULT_PROPS.content.split('\n');
      createComponent({ isHighlighted: true });

      expect(findChunkLines().length).toBe(splitContent.length);

      expect(findChunkLines().at(0).props()).toMatchObject({
        number: DEFAULT_PROPS.startingFrom + 1,
        content: splitContent[0],
        language: DEFAULT_PROPS.language,
        blamePath: DEFAULT_PROPS.blamePath,
      });
    });

    it('does not scroll to route hash if last chunk is not loaded', () => {
      expect(scrollToElement).not.toHaveBeenCalled();
    });

    it('scrolls to route hash if last chunk is loaded', () => {
      createComponent({ totalChunks: DEFAULT_PROPS.chunkIndex + 1 });
      expect(scrollToElement).toHaveBeenCalledWith(hash, { behavior: 'auto' });
    });
  });
});
