import { api, LightningElement, track } from "lwc";

export default class DraggableTable extends LightningElement {
    @track dragStart;
    @track ElementList = [];

    classList;

    @api
    get rows() {
        return this.ElementList;
    }

    set rows(value) {
        this.ElementList = value.map((element, index) => {
            return {
                ...element,
                index
            };
        });
    }

    DragStart(event) {
        this.dragStart = event.target.title;
        this.classList = event.target.classList;
        this.classList.add("drag");
    }

    DragOver(event) {
        event.preventDefault();
        this.classList.remove("drag");
        return false;
    }

    Drop(event) {
        event.stopPropagation();

        const DragValName = this.dragStart;
        const DropValName = event.target.title;

        if (DragValName === DropValName) {
            return false;
        }

        const index = DropValName;
        const currentIndex = DragValName;
        const newIndex = DropValName;

        console.log("currentIndex: " + currentIndex);
        console.log("newIndex: " + newIndex);

        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };

        this.ElementList.move(currentIndex, newIndex);
    }
}