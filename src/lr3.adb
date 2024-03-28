with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Lr3 is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;
   Storage_Size : Integer := 3;
   Item_Numbers : Integer := 6;
   consumers : Integer := 2;
   producers : Integer := 2;

   procedure Manager (Storage_Size : in Integer; Item_Numbers : in Integer) is
      Storage : List;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

   task type Producer is
         entry Start ( id :Integer; Item_Numbers : in Integer);
         end Producer;

      task type Consumer is
         entry Start ( id :Integer; Item_Numbers : in Integer);
         end Consumer;

      task body Producer is
         Item_Numbers : Integer;
         id : Integer;
      begin
           accept Start ( id :Integer; Item_Numbers : in Integer) do
         Producer.Item_Numbers := Item_Numbers;
         Producer.id := id;
           end Start;

         for i in 1 .. Item_Numbers loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & i'Img);
            Put_Line ("Producer " & id'Img & " added item " & i'Img);

            Access_Storage.Release;
            Empty_Storage.Release;
            delay 1.5;
         end loop;

      end Producer;

      task body Consumer is
         Item_Numbers : Integer;
         id : Integer;
      begin
           accept Start ( id :Integer; Item_Numbers : in Integer) do
                Consumer.Item_Numbers := Item_Numbers;
                Consumer.id := id;
           end Start;

         for i in 1 .. Item_Numbers loop
            Empty_Storage.Seize;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Consumer " & id'Img & " took " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full_Storage.Release;

            delay 2.0;
         end loop;

      end Consumer;

      c : array(1..consumers) of Consumer;
      p : array(1..producers) of Producer;
   begin
        for i in 1..consumers loop
         --Consumer.Start (i, Item_Numbers);
         c(i).Start(i, Item_Numbers);
        end loop;
        for i in 1..producers loop
         --Producer.Start (i, Item_Numbers);
         p(i).Start(i, Item_Numbers);
        end loop;
   end Manager;
begin
   Manager(Storage_Size, Item_Numbers);
end Lr3;
