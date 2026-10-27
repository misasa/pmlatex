require 'spec_helper'

RSpec.describe Pmlatex::Tex do
  it 'reads the historical report title, ID, author and include paths' do
    tex = described_class.from_file(fixture('yamanaka_report.tex'))
    expect(tex.title).to eq('A possible target for MISIP-2015')
    expect(tex.bib_id).to eq('20150413140738-506731')
    expect(tex.author_fullnames).to eq(['PML'])
    expect(tex.include_files).to include('tables/stone_list0', 'tables/status0')
  end

  it 'parses a fixed date without depending on the current day' do
    tex = described_class.new(document)
    tex.parse
    expect([tex.year, tex.mon, tex.mday]).to eq([2014, 4, 5])
    expect(tex.title).to eq('Example report')
    expect(tex.bib_id).to eq('bib-1')
  end

  it 'preserves exact citation IDs, order and command categories, excluding full-line comments' do
    tex = described_class.new(<<~'TEX')
      \citeyearpar{year-1} \citeauthor{author-1}
      \citep{parenthetical-1} \citep{parenthetical-2}
      \cite{plain-1} \refdream{dream-1}
      % \cite{ignored} \input{ignored}
      \input{section}
      \include{appendix}
    TEX
    tex.parse
    expect(tex.citeyearpars).to eq(%w[year-1 author-1])
    expect(tex.citeps).to eq(%w[parenthetical-1 parenthetical-2])
    expect(tex.cites).to eq(['plain-1'])
    expect(tex.refdreams).to eq(['dream-1'])
    # One include/input per line is the existing parser's supported shape.
    expect(tex.include_files).to eq(['section', 'appendix'])
  end

  {
    'Nakamura, E.' => ['Nakamura, E.'],
    'YS and TK' => ['YS', 'TK'],
    'Nakamura, E., Makishima, A., and Yachi, Y.' => ['Nakamura, E.', 'Makishima, A.', 'Yachi, Y.'],
    'Last1, A. B., First1 Jr. Last1, Yusuke Yachi, and Last2, D.' => ['Last1, A. B.', 'Last1, First1 Jr.', 'Yachi, Yusuke', 'Last2, D.']
  }.each do |author, expected|
    it "parses all authors in #{author.inspect}" do
      tex = described_class.new(document(author: author))
      expect(tex.author_fullnames).to eq(expected)
    end
  end

  {
    "\\begin{document}\n\\maketitle\n% FILEPATH START\nbody" => "\\begin{document}\n\\maketitle\nID\n% FILEPATH START\nbody",
    "\\begin{document}\n\\maketitle\nbody" => "\\begin{document}\n\\maketitle\nID\nbody",
    "header\n\\begin{document}\nbody" => "header\n\\begin{document}\nID\nbody"
  }.each_with_index do |(source, expected), index|
    it "inserts the ID at priority position #{index + 1} and saves the full source" do
      tex = described_class.new(source)
      tex.insert_bib_line('ID')
      tex.save('result.tex')
      expect(File.read('result.tex')).to eq(expected + "\n")
    end
  end

  it 'rejects insertion without an anchor and leaves the source intact' do
    tex = described_class.new('unanchored text')
    expect { tex.insert_bib_line('ID') }.to raise_error(/Could not find/)
    expect(tex.src).to eq('unanchored text')
  end

  it 'characterizes metadata at the first byte as currently unrecognized' do
    tex = described_class.new("\\title{first line}\n")
    tex.parse
    expect(tex.title).to be_nil
  end

  it 'characterizes comma-separated citation keys as one unsplit lookup ID' do
    tex = described_class.new('\\cite{one,two}')
    tex.parse
    expect(tex.cites).to eq(['one,two'])
  end
end
