defmodule Deconzex.SlipTest do
  use ExUnit.Case

  describe "init" do
    test "init returns empty binary" do
      assert {:ok, <<>>} = Deconzex.Slip.init([])
    end
  end

  describe "process_data" do
    test "frame with END" do
      {:ok, framer} = Deconzex.Slip.init([])
      frame = <<0x01, 0x02, 0xC0>>

      assert {:ok, [<<0x01, 0x02>>], ^framer} = Deconzex.Slip.remove_framing(frame, framer)
    end

    test "frame with escaped END character" do
      frame = <<0x01, 0xDB, 0xDC, 0x02, 0xC0>>

      assert {:ok, [<<0x01, 0xC0, 0x02>>], <<>>} == Deconzex.Slip.remove_framing(frame, <<>>)
    end

    test "frame with escaped ESC character" do
      frame = <<0x01, 0xDB, 0xDD, 0x02, 0xC0>>

      assert {:ok, [<<0x01, 0xDB, 0x02>>], <<>>} == Deconzex.Slip.remove_framing(frame, <<>>)
    end

    test "data ends without END" do
      frame = <<0x01, 0x02, 0x03>>

      assert {:in_frame, [], <<0x01, 0x02, 0x03>>} == Deconzex.Slip.remove_framing(frame, <<>>)
    end

    test "multiple frames only returns the first frame" do
      frame = <<0x01, 0x02, 0xC0, 0x03, 0xC0>>

      assert {:ok, [<<0x01, 0x02>>, <<0x03>>], <<>>} == Deconzex.Slip.remove_framing(frame, <<>>)
    end

    test "drops empty frames" do
      frame = <<0xC0, 0x01, 0x02, 0xC0>>

      assert {:ok, [<<0x01, 0x02>>], <<>>} == Deconzex.Slip.remove_framing(frame, <<>>)
    end
  end

  describe "encode" do
    test "puts an END on each end of the frame" do
      frame = <<0x01, 0x02>>

      assert {:ok, <<0xC0, 0x01, 0x02, 0xC0>>, _} = Deconzex.Slip.add_framing(frame, <<>>)
    end

    test "escapes END characters" do
      frame = <<0x01, 0xC0, 0x02>>

      assert {:ok, <<0xC0, 0x01, 0xDB, 0xDC, 0x02, 0xC0>>,_} = Deconzex.Slip.add_framing(frame, <<>>)
    end

    test "escapes ESC characters" do
      frame = <<0x01, 0xDB, 0x02>>

      assert {:ok, <<0xC0, 0x01, 0xDB, 0xDD, 0x02, 0xC0>>, _} = Deconzex.Slip.add_framing(frame, <<>>)
    end
  end
end
